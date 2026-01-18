extends Node2D

@onready var raycast := $"RayCast2D"

const mobs := {
	"forest" : {
		"skelet" : preload("res://src/entity/skelet/skelet.tscn"),
	},
	"desert" : {
		"big_cactus" : preload("res://src/entity/cactus/big_cactus/big_cactus.tscn"),
		"small_cactus" : preload("res://src/entity/cactus/small_cactus/small_cactus.tscn"),
	},
}


func multiply_health(mob: CharacterBody2D, multiplyer: float) -> CharacterBody2D:
	mob.max_health *= multiplyer
	mob.current_health *= multiplyer
	mob.hp_bar.max_value = mob.max_health
	mob.hp_bar.value = mob.current_health
	return mob


func spawn(world_seed: int, screen: Vector2	, location: int, distance: int) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = location + distance + world_seed
	
	self.position.x = screen.x - 10
	self.position.y = 0
	
	while raycast.is_colliding(): # Поиск свободного места для моба
		self.position.y = rng.randf_range(0.0, screen.y)
		await get_tree().create_timer(0.1).timeout
	
	var mob: PhysicsBody2D
	if location == 0:
		mob = mobs["forest"][mobs["forest"].keys().pick_random()].instantiate()
	elif location == 1:
		if rng.randi_range(0, 5) == 0:
			mob = mobs["forest"][mobs["forest"].keys().pick_random()].instantiate()
		else:
			mob = mobs["desert"][mobs["desert"].keys().pick_random()].instantiate()
	
	add_child(mob)
	mob.top_level = true
	mob.position = self.global_position
	
	if location > 0:
		mob = multiply_health(mob, 1.5 * location + 1)
	
	if rng.randf() <= 0.1:
		mob.scale *= 2
		multiply_health(mob, 2)
		mob.damage *= 2
	if rng.randf() <= 0.1:
		mob.modulate.r = 200
		mob.speed *= 2
		mob.damage *= 2
