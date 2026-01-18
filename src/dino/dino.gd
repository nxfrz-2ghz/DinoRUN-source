extends CharacterBody2D

@onready var M := $"/root/Main"
@onready var arm := $RightArm

@onready var coyote_time := $Timers/CoyoteTime
@onready var dash_cooldown := $Timers/DashCD
@onready var leave_damage_delay := $Timers/LeaveDamageDelay
@onready var anim_sprite := $AnimatedSprite2D
@onready var collision := $CollisionShape2D
@onready var particles := $Particles
@onready var damage_audio_player := $Audio/DamageAudioPlayer

const txt_particle := preload("res://src/entity/txt_particle/txt_particle.tscn")
const ghost_particle := preload("res://src/entity/ghost/ghost.tscn")

const SPEED := 120.0
const DASH_POWER := 2540.0
const JUMP_VELOCITY := -350.0
const JUMP_BUFFER_TIME := 0.15

const MAX_HEALTH := 10.0
var current_health := MAX_HEALTH
var current_effects: Dictionary

var was_on_floor := true
var jump_buffer_timer := 0.0

var alive := false


func _ready() -> void:
	velocity.x += 300


func spawn_text(text: String, color: Color) -> void:
	var n := txt_particle.instantiate()
	n.txt = text
	n.color = color
	M.E.add_child(n)
	n.position = self.position
	n.label.add_theme_font_size_override("font_size", 18)


func receive_damage(dmg: float) -> void:
	current_health -= dmg
	if current_health > MAX_HEALTH * 1.5:
		current_health = MAX_HEALTH * 1.5
	
	M.C.hp_bar.set_value(current_health / MAX_HEALTH)
	
	if dmg > 0:
		spawn_text(str(-dmg) + "!", Color.RED)
		damage_audio_player.pitch_scale = randf_range(1.0, 1.2) - dmg / 10
		damage_audio_player.play()
	else:
		spawn_text("+" + str(-dmg) + "!", Color.GREEN)
	
	if current_health <= 0:
		get_tree().reload_current_scene()


func receive_effects(effects: Dictionary) -> void:
	# Создаём копии эффектов, чтобы не модифицировать исходный словарь
	for effect_name: String in effects:
		
		if !current_effects.has(effect_name): M.C.hp_bar.add_effect(effect_name)
		
		var effect = effects[effect_name].duplicate()
		effect["_timer"] = 0.0
		current_effects[effect_name] = effect


func _moving() -> void:
	if !alive: return
	var direction := Input.get_axis("ui_left", "ui_right")
	
	if direction != 0:
		velocity.x += direction * SPEED * Engine.time_scale / ((30 * int(!is_on_floor())) + 1)
		#anim_sprite.flip_h = !bool(direction + 1)
		anim_sprite.animation = "run"


func _braking() -> void:
	if velocity:
		anim_sprite.speed_scale = velocity.x / 100 * Engine.time_scale
		
		if is_on_floor():
			velocity.x /= 1.5
		else:
			velocity.x /= 1.01
	
	if abs(velocity.x) < 0.01:
		velocity.x = 0
		anim_sprite.animation = "idle"
		anim_sprite.speed_scale = 3


func _set_left_right_rotation_arm(x: float, center: float, is_gun: bool) -> void:
	if x < center:
		if !is_gun: arm.rotation = 135
		anim_sprite.flip_h = true
		arm.weapon.scale.y = -1.0
	else:
		if !is_gun: arm.rotation = 0
		anim_sprite.flip_h = false
		arm.weapon.scale.y = 1.0


func _rotating() -> void:
	var is_gun: bool = arm.weapon.WEAPONS[arm.weapon.inventory[1]["name"]].has("power")
	if OS.has_feature("mobile"):
		var j2 = M.C.mobile.j2
		var j1 = M.C.mobile.j1
		
		if j2.is_pressed and j2.output != Vector2.ZERO:
			# ПРИНУДИТЕЛЬНЫЙ ПОВОРОТ (СТРЕЛЬБА)
			var dir = j2.output
			arm.rotation = dir.angle()
			_set_left_right_rotation_arm(dir.x, 0, is_gun)
			arm.weapon.shoot()
		else:
			# ПОВОРОТ ПРИ ХОДЬБЕ
			var move_x = j1.output.x
			if move_x != 0:
				anim_sprite.flip_h = move_x < 0
				# Разворачиваем руку в сторону движения (0 радиан - право, PI радиан - лево)
				@warning_ignore("incompatible_ternary")
				arm.rotation = 0 if move_x > 0 else PI
				# Отражаем оружие, чтобы оно не было перевернутым при ходьбе влево
				arm.weapon.scale.y = -1.0 if move_x < 0 else 1.0
				
				# Инверсия анимации бега спиной вперед (если нужно)
				anim_sprite.speed_scale = 1.0 # Сброс, если логика сложнее — подправь
	else:
		# ЛОГИКА ДЛЯ ПК (МЫШЬ)
		var mouse_pos = get_global_mouse_position()
		if is_gun: arm.look_at(mouse_pos)
		_set_left_right_rotation_arm(mouse_pos.x, global_position.x, is_gun)


func process_effects() -> void:
	if current_effects.is_empty(): return
	
	var effects_to_remove := []
	
	for effect_name: String in current_effects:
		var effect: Dictionary = current_effects[effect_name]
		
		# Увеличиваем timer
		effect["_timer"] += get_physics_process_delta_time()
		
		# Применяем эффект если прошел delay
		if effect.has("damage") and effect.has("delay"):
			if effect["_timer"] >= effect["delay"]:
				receive_damage(effect["damage"])
				particles.start(effect_name)
				effect["_timer"] = 0.0
		elif effect.has("damage"):
			# Если delay не указан, наносим урон каждый кадр
			receive_damage(effect["damage"])
		
		# Уменьшаем время эффекта
		effect["time"] -= get_physics_process_delta_time()
		
		# Удаляем эффект если время истекло
		if effect["time"] <= 0:
			effects_to_remove.append(effect_name)
			M.C.hp_bar.remove_effect(effect_name)
			spawn_text(effect_name + " прошёл", Color.AQUA)
	
	# Удаляем истекшие эффекты
	for effect_name: String in effects_to_remove:
		current_effects.erase(effect_name)


func _spawn_ghost() -> void:
		var ghost: Sprite2D = ghost_particle.instantiate()
		ghost.texture = anim_sprite.get_sprite_frames().get_frame_texture(anim_sprite.animation, anim_sprite.frame)
		ghost.flip_h = anim_sprite.flip_h
		M.E.add_child(ghost)
		ghost.position = self.position


func dash(direction: int) -> void:
	_spawn_ghost()
	# вычисление после деления ослабляет рывок в воздухе
	velocity.x += DASH_POWER * direction / ((10 * int(!is_on_floor())) + 1) / Engine.time_scale
	dash_cooldown.start()
	
	for i in range(3):
		await get_tree().create_timer(0.05).timeout
		_spawn_ghost()


func _physics_process(delta: float) -> void:
	
	self.position.x -= M.E.ground.speed * Engine.time_scale
	
	jump_buffer_timer = max(jump_buffer_timer - delta, 0.0) # Уменьшение jump_buffer_timer
	
	if collision.disabled == true and velocity.y > 0:
		collision.disabled = false
	
	if not is_on_floor():
		velocity += get_gravity() * delta
		
		if was_on_floor:
			coyote_time.start()
			was_on_floor = false
	else:
		was_on_floor = true
		
		# При спускании с платформы на один кадр отключается коллизия
		if Input.is_action_just_pressed("ui_down") and !$Raycasts/FallThrough.is_colliding():
			if !alive: return
			collision.disabled = true
			velocity.y = 1200
	
	if alive: 
		if dash_cooldown.is_stopped():
			if Input.is_action_just_pressed("l_dash"):
				dash(-1)
			elif Input.is_action_just_pressed("r_dash"):
				dash(1)
		
		if Input.is_action_pressed("lmb") and !OS.has_feature("mobile"):
			arm.weapon.shoot()
	
		if Input.is_action_just_pressed("ui_up"): # Добавляем прыжок в jump_buffer
			jump_buffer_timer = JUMP_BUFFER_TIME
	
	# Если jump_buffer не истек или coyote_time, то делается прыжок
	# В нем отключается коллизия, чтобы можно было запрыгнуть на платформу
	if jump_buffer_timer > 0.0 and (is_on_floor() or !coyote_time.is_stopped()): 
		velocity.y = JUMP_VELOCITY
		collision.disabled = true
	
	_moving()
	_braking()
	_rotating()
	process_effects()
	
	if self.position.x < -5:
		if leave_damage_delay.is_stopped():
			velocity.x += 80000.0 / ((10 * int(!is_on_floor())) + 1)
			M.C.screen_text.add_message("YOU CAN'T LEAVE")
			leave_damage_delay.start()
	
	if self.position.x > M.screen.x + 5:
		if leave_damage_delay.is_stopped():
			velocity.x += -80000.0 / ((10 * int(!is_on_floor())) + 1)
			M.C.screen_text.add_message("YOU CAN'T LEAVE")
			leave_damage_delay.start()
	
	@warning_ignore("integer_division")
	if self.position.y > M.screen.y + 5:
		if leave_damage_delay.is_stopped():
			position.y = 0
			M.C.screen_text.add_message("YOU CAN'T LEAVE")
			leave_damage_delay.start()
	
	move_and_slide()
