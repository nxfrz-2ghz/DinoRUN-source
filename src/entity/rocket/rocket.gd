extends RigidBody2D

@onready var M := $"/root/Main"

const ACCELERATION := 200.0
const ROTATION_SPEED := 5.0
const explosion := preload("res://src/entity/explosion/explosion.tscn")

@export var damage := 0

var velocity := Vector2.ZERO


func _physics_process(delta: float) -> void:
	self.position.x += M.E.ground.speed * Engine.time_scale
	
	# Ускорение в направлении, куда направлен узел
	var direction := Vector2(cos(rotation), sin(rotation))
	velocity += direction * ACCELERATION * delta
	self.position += velocity * delta
	
	var mobs = get_tree().get_nodes_in_group("mobs")
	var closest_distance: float = INF
	var closest_mob: CharacterBody2D
	
	for mob in mobs:
		var dist = self.global_position.distance_to(mob.global_position)
		if dist < closest_distance:
			closest_distance = dist
			closest_mob = mob
	
	# Вращение к ближайшему мобу
	if closest_mob:
		var direction_to_mob := (closest_mob.global_position - self.global_position).normalized()
		var target_rotation := direction_to_mob.angle()
		self.rotation = lerp_angle(self.rotation, target_rotation, ROTATION_SPEED * delta)


func boom() -> void:
	var inst: Area2D = explosion.instantiate()
	M.E.add_child(inst)
	inst.global_position = self.global_position
	queue_free()


func _on_body_entered(body: Node) -> void:
	if body.has_method("receive_damage") and damage != 0: body.receive_damage(damage)
	boom()


func _on_timer_timeout() -> void:
	boom()
