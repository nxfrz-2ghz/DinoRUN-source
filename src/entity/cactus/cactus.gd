extends "res://src/entity/mob/mob.gd"


func _ready() -> void:
	super()
	anim_sprite.frame = randi_range(0, 8)


func attack() -> void:
	if abs(M.E.dino.position.x - self.position.x) < 30 and abs(M.E.dino.position.y - self.position.y) < 30:
		M.E.dino.receive_damage(damage)


func _physics_process(delta: float) -> void:
	if !alive: queue_free()
	self.position.x -= M.E.ground.speed * Engine.time_scale	
	super(delta)
	move_and_slide()
