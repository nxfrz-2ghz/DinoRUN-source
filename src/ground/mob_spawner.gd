extends Node2D

@onready var raycast := $"RayCast2D"

const mob_weapon := preload("res://src/weapon/mob_weapon.tscn")

const mobs := {
	"forest" : {
		"skelet" : preload("res://src/entity/skelet/skelet.tscn"),
		"rocks" : preload("res://src/entity/rocks/rocks.tscn"),
	},
	"desert" : {
		"big_cactus" : preload("res://src/entity/cactus/big_cactus/big_cactus.tscn"),
		"small_cactus" : preload("res://src/entity/cactus/small_cactus/small_cactus.tscn"),
	},
}

const mob_spawn_chances := {
	"forest" : {
		"skelet" : 70,
		"rocks" : 30,
	},
	"desert" : {
		"big_cactus" : 40,
		"small_cactus" : 60,
	},
}


func multiply_health(mob: CharacterBody2D, multiplyer: float) -> CharacterBody2D:
	mob.max_health *= multiplyer
	mob.current_health *= multiplyer
	mob.hp_bar.max_value = mob.max_health
	mob.hp_bar.value = mob.current_health
	return mob


func pick_mob_by_chance(rng: RandomNumberGenerator, biome: String) -> String:
	var chances = mob_spawn_chances[biome]
	var total_chance = 0
	
	for mob_name in chances.keys():
		total_chance += chances[mob_name]
	
	var random_value = rng.randi_range(1, total_chance)
	var current_sum = 0
	
	for mob_name in chances.keys():
		current_sum += chances[mob_name]
		if random_value <= current_sum:
			return mob_name
	
	return chances.keys()[0]


func spawn(world_seed: int, screen: Vector2	, location: int, distance: int) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = location + distance + world_seed
	
	self.position.x = screen.x - 10
	self.position.y = 0
	
	while raycast.is_colliding(): # Поиск свободного места для моба
		self.position.y = rng.randf_range(0.0, screen.y)
		await get_tree().create_timer(0.1).timeout
	
	var mob: CharacterBody2D
	
	if location == 0:
		var mob_name = pick_mob_by_chance(rng, "forest")
		mob = mobs["forest"][mob_name].instantiate()
	elif location == 1:
		if rng.randi_range(0, 5) == 0:
			var mob_name = pick_mob_by_chance(rng, "forest")
			mob = mobs["forest"][mob_name].instantiate()
		else:
			var mob_name = pick_mob_by_chance(rng, "desert")
			mob = mobs["desert"][mob_name].instantiate()
	
	add_child(mob)
	mob.top_level = true
	mob.position = self.global_position
	
	if location > 0:
		mob = multiply_health(mob, 1.5 * location + 1)
	
	if rng.randf() <= 0.1:
		mob.scale *= 2
		multiply_health(mob, 2)
		mob.speed *= 0.8
		mob.damage *= 2
	if rng.randf() <= 0.1:
		mob.modulate.r = 200
		mob.speed *= 2
		mob.damage *= 1.2
	if rng.randf() <= 0.05:
		multiply_health(mob, 0.8)
		mob.speed *= 0.9
		mob.add_child(mob_weapon.instantiate())
