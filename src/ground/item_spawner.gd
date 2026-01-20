extends Node2D

const ITEM := preload("res://src/entity/item/item.tscn")

const items := {
	"meat": {
		"weapon": false,
		"texture": preload("res://res/sprites/items/meat/meat.png"),
	},
	"coin": {
		"weapon": false,
		"frames": preload("res://res/sprites/items/coin/frames.tres"),
		"light_color": Color.BISQUE,
		"light_energy": 1.0,
	},
	"pistol": {
		"weapon": true,
		"texture": preload("res://res/sprites/guns/3Pistol03.png"),
	},
	"shotgun": {
		"weapon": true,
		"texture": preload("res://res/sprites/guns/2Shotgun02.png"),
	},
	"P90": {
		"weapon": true,
		"texture": preload("res://res/sprites/guns/5AssaultRifle05.png"),
	},
	"M4": {
		"weapon": true,
		"texture": preload("res://res/sprites/guns/7Assoultrifle07.png"),
	},
	"rocket_launcher": {
		"weapon": true,
		"texture": preload("res://res/sprites/guns/4Explosive04.png"),
	},
	"sniper_rifle": {
		"weapon": true,
		"texture": preload("res://res/sprites/guns/4SniperRifle04.png"),
	},
	"toxic_gun": {
		"weapon": true,
		"texture": preload("res://res/sprites/guns/Toxic Gun.png"),
	},
	"fire_torch": {
		"weapon": true,
		"frames": preload("res://res/sprites/guns/torch/fire_torch_frames.tres"),
	},
	"base_sword": {
		"weapon": true,
		"texture": preload("res://res/sprites/guns/base_sword.png"),
	},
}

var i: int = 0


func spawn(world_seed: int, pos_x: int, location: int, distance: int) -> void:
	var item: PhysicsBody2D = ITEM.instantiate()
	var rng := RandomNumberGenerator.new()
	rng.seed = location + distance + world_seed + i
	i += 1
	
	self.position.x = pos_x - 10 - rng.randf_range(0, float(pos_x)/4)
	self.position.y = -10
	
	var current_item: String
	
	if rng.randi_range(0, 20) == 0:
		var weapons = items.keys().filter(func(id): return items[id].weapon)
		current_item = weapons[randi() % weapons.size()]
	else:
		if rng.randi_range(0, 10) == 0:
			current_item = "meat"
		else:
			current_item = "coin"
	
	item.item = current_item
	item.lvl = location + int(randi_range(0, 10) == 10)
	
	if items[current_item].get("texture"):
		item.texture = items[current_item]["texture"]
	if items[current_item].get("frames"):
		item.frames = items[current_item]["frames"]
	if items[current_item].get("light_color"):
		item.light_color = items[current_item]["light_color"]
	if items[current_item].get("light_energy"):
		item.light_energy = items[current_item]["light_energy"]
	
	add_child(item)
	item.top_level = true
	item.position = self.global_position
