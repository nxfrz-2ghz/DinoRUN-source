extends Node

@onready var M := $"/root/Main"
@onready var weapon: Node2D = M.E.dino.arm.weapon
@onready var audio := $AudioStreamPlayer

const S := {
	"coin": {
		"value" : 100,
		"sound" : preload("res://res/sounds/items/coin.mp3"),
	},
	"meat": {
		"heal" : 2,
		"sound" : preload("res://res/sounds/items/eat.mp3"),
	},
}

const max_distance: float = 50.0
const min_time_scale: float = 0.3

const camera_default_pos := Vector2(320.0, 180.0)


func play(sound: AudioStream) -> void:
	audio.stream = sound
	audio.play()


func _physics_process(_delta: float) -> void:
	var drops = get_tree().get_nodes_in_group("drop")
	var closest_distance = max_distance
	var closest_drop: RigidBody2D
	
	for drop in drops:
		var dist = M.E.dino.global_position.distance_to(drop.global_position)
		if dist < closest_distance:
			closest_distance = dist
			closest_drop = drop
	
	if not closest_drop:
		Engine.time_scale = 1
		return
	
	if closest_drop.item == "PC":
		if Input.is_action_just_pressed("pickup") and !M.C.get_node("PCUI").visible:
			M.C.get_node("PCUI").activate()
	
	elif closest_drop.item in weapon.weapons.keys() and Input.is_action_just_pressed("pickup"):
		for child in closest_drop.get_children():
			if child.name == "cage":
				if M.S.upgrades.coins >= 1000:
					M.S.upgrades.coins -= 1000
				else:
					return
		weapon.add_item(closest_drop.item, closest_drop.lvl)
		closest_drop.queue_free()
	
	elif M.E.ground.item_spawner.items["consumables"].get(closest_drop.item):
		if closest_drop.item == "meat":
			M.E.dino.receive_damage(-S["meat"]["heal"])
		
		if closest_drop.item == "coin":
			M.E.dino.spawn_text("+" + str(S["coin"]["value"]), Color.GOLD)
			M.S.upgrades.coins += 100
		
		play(S[closest_drop.item]["sound"])
		closest_drop.queue_free()
	
	
	elif M.E.ground.item_spawner.items["acessories"].get(closest_drop.item) and Input.is_action_just_pressed("pickup"):
		
		if closest_drop.item == "health_potion":
			M.E.dino.receive_damage(-5)
			closest_drop.queue_free()
			return
		
		M.S.acs.add(closest_drop.item)
		M.C.hp_bar.add_acs(closest_drop.item, closest_drop.texture)
		closest_drop.queue_free()
	
	
	var target_scale = remap(closest_distance, 0, max_distance, min_time_scale, 1.0)
	
	if closest_drop.item in weapon.weapons.keys():
		Engine.time_scale = clamp(target_scale, min_time_scale, 1.0)
