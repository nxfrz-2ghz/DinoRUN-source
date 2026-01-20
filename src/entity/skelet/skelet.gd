extends "res://src/entity/mob/mob.gd"

@onready var raycast := $RayCast2D
@onready var attack_delay := $Timers/AttackDelay
@onready var jump_delay := $Timers/JumpDelay

var rotated := false


func despawn() -> void:
	super()
	anim_sprite.speed_scale = 1
	anim_sprite.play("die")


func moving() -> void:
	
	if anim_sprite.animation == "walking":
		
		if abs(M.E.dino.position.x - self.position.x) < 30 and abs(M.E.dino.position.y - self.position.y) < 30: return
		
		velocity.x += speed * ((int(!rotated)*2)-1)
		
		if jump_delay.is_stopped():
			
			if raycast.is_colliding():
				jump_delay.start()
			
			# Прыжок, если игрок над мобом
			if abs(M.E.dino.position.x - self.position.x) < 50 and M.E.dino.position.y - self.position.y < -30:
				velocity.y = jump_velocity
				collider.disabled = true


func braking() -> void:
	if velocity:
		anim_sprite.speed_scale = velocity.x / 100 + M.E.ground.speed * Engine.time_scale
		
		if is_on_floor():
			velocity.x /= 1.5 / Engine.time_scale
		else:
			velocity.x /= 1.01 / Engine.time_scale
	
	if abs(velocity.x) < 0.01:
		velocity.x = 0
		anim_sprite.speed_scale = M.E.ground.speed


func rotating() -> void:
	if anim_sprite.animation == "attack": return
	
	if M.E.dino.position.x < self.position.x:
		rotated = true
		anim_sprite.scale.x = -0.5
		raycast.position.x = -8
	else:
		rotated = false
		anim_sprite.scale.x = 0.5
		raycast.position.x = 8


func attack() -> void:
	if abs(M.E.dino.position.x - self.position.x) < 30 and abs(M.E.dino.position.y - self.position.y) < 30:
		if attack_delay.is_stopped() and anim_sprite.animation != "attack":
			anim_sprite.play("attack")
			attack_delay.start()


func _physics_process(delta: float) -> void:
	if !alive: return
	
	self.position.x -= M.E.ground.speed * Engine.time_scale
	
	if collider.disabled == true and velocity.y > 0:
		collider.disabled = false
	
	if is_on_floor():
		moving()
	
	attack()
	rotating()
	
	super(delta)
	
	move_and_slide()


func _on_animated_sprite_2d_animation_finished() -> void:
	if anim_sprite.animation == "attack":
		anim_sprite.play("walking")
	if anim_sprite.animation == "die":
		queue_free()


func _on_attack_delay_timeout() -> void:
	if abs(M.E.dino.position.x - self.position.x) < 30 and abs(M.E.dino.position.y - self.position.y) < 30:
		if alive: M.E.dino.receive_damage(damage)


func _on_jump_delay_timeout() -> void:
	if raycast.is_colliding():
		velocity.y = jump_velocity
