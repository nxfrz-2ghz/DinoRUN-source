extends RigidBody2D

@onready var despawn_timer := $Timer

var damage: float = 0.0
var screen_speed: float
var despawn_delay: float:
	set(value):
		despawn_delay = value
		despawn_timer.wait_time = value
		despawn_timer.start()
var effects: Dictionary


func _integrate_forces(state) -> void:
	var trans = state.transform
	trans.origin.x -= screen_speed * Engine.time_scale
	state.transform = trans


func _physics_process(_delta: float) -> void:
	if self.position.y > DisplayServer.window_get_size().y: queue_free()
	if sleeping and !despawn_delay: queue_free()


func _on_timer_timeout() -> void:
	queue_free()


func _on_body_entered(body: Node) -> void:
	if body.has_method("receive_damage") and damage != 0:
		body.receive_damage(damage)
		queue_free()
	if body.has_method("receive_effects") and effects:
		body.receive_effects(effects)
		queue_free()
	
