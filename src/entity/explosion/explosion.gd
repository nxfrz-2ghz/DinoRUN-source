extends Area2D

@export var damage: float = 25.0
@export var falloff_factor = 0.7
@export var force: float = 5000.0


func _ready():
	await get_tree().create_timer(0.05).timeout
	$Particles.emitting = true
	apply_explosion_effects()


func apply_explosion_effects():
	for body in get_overlapping_bodies():
		if not body: 
			continue
		if body is TileMapLayer:
			continue
		
		var distance: float = global_position.distance_to(body.global_position)
		var calculated_damage: float = (round(damage / (1.0 + distance * falloff_factor)*100))/100
		var calculated_force: float = force / (1.0 + distance * falloff_factor)
		
		if body is CharacterBody2D:
			var dir = (body.global_position - global_position).normalized()
			body.velocity += dir * calculated_force
			body.receive_damage(calculated_damage)


func _on_particles_finished() -> void:
	queue_free()
