extends "res://src/entity/mob/mob.gd"


func _ready() -> void:
	super()
	anim_sprite.frame = randi_range(0, 5)


func _physics_process(delta: float) -> void:
	if !alive: queue_free()
	self.position.x -= M.E.ground.speed * Engine.time_scale	
	super(delta)
	move_and_slide()
