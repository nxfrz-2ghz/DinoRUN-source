extends CharacterBody2D

@onready var M := $"/root/Main"
@onready var anim_sprite := $AnimatedSprite2D
@onready var collider := $CollisionShape2D
@onready var particles := $Particles
@onready var hp_bar := $HPBar
@onready var damage_audio_player := $Audio/DamageAudioPlayer
@onready var die_audio_player := $Audio/DieAudioPlayer

const txt_particle := preload("res://src/entity/txt_particle/txt_particle.tscn")

@export var speed := 0.0
@export var jump_velocity := -250.0
@export var max_health := 5.0
@export var damage := 0.0

var current_effects: Dictionary
var current_health: float
var alive := true


func _ready() -> void:
	current_health = max_health
	hp_bar.max_value = max_health
	hp_bar.value = current_health


func spawn_text(txt: String) -> void:
	var color := Color.WHITE
	
	if current_effects.has("poison"): color = Color.LAWN_GREEN
	
	var n := txt_particle.instantiate()
	n.txt = txt
	n.color = color
	M.E.add_child(n)
	n.position = self.position


func receive_damage(dmg: float) -> void:
	if !alive: return
	
	current_health -= dmg
	hp_bar.value = current_health
	damage_audio_player.pitch_scale = randf_range(1.0, 1.2) - dmg / 10
	damage_audio_player.play()
	spawn_text(str(-dmg) + "!")
	
	if current_health <= 0:
		despawn()


func receive_effects(effects: Dictionary) -> void:
	# Создаём копии эффектов, чтобы не модифицировать исходный словарь
	for effect_name: String in effects:
		var effect = effects[effect_name].duplicate()
		effect["_timer"] = 0.0
		current_effects[effect_name] = effect


func process_effects() -> void:
	if current_effects.is_empty(): return
	
	var effects_to_remove := []
	
	for i: String in current_effects:
		var effect: Dictionary = current_effects[i]
		
		# Увеличиваем timer
		effect["_timer"] += get_physics_process_delta_time()
		
		# Применяем эффект если прошел delay
		if effect.has("damage") and effect.has("delay"):
			if effect["_timer"] >= effect["delay"]:
				receive_damage(effect["damage"])
				particles.start(i)
				effect["_timer"] = 0.0
		elif effect.has("damage"):
			# Если delay не указан, наносим урон каждый кадр
			receive_damage(effect["damage"])
		
		# Уменьшаем время эффекта
		effect["time"] -= get_physics_process_delta_time()
		
		# Удаляем эффект если время истекло
		if effect["time"] <= 0:
			effects_to_remove.append(i)
			spawn_text(i + " прошёл")
	
	# Удаляем истекшие эффекты
	for effect_name: String in effects_to_remove:
		current_effects.erase(effect_name)


func braking() -> void:
	if velocity:
		if is_on_floor():
			velocity.x /= 1.5 / Engine.time_scale
		else:
			velocity.x /= 1.01 / Engine.time_scale
	
	if abs(velocity.x) < 0.01:
		velocity.x = 0


func despawn() -> void:
	hp_bar.queue_free()
	die_audio_player.play()
	alive = false
	collider.queue_free()


func _physics_process(delta: float) -> void:
	process_effects()
	braking()
	
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if self.position.y > 1000:
		queue_free()
