extends Node

@onready var M := $"/root/Main"
@onready var weapon: Node2D = M.E.dino.get_node_or_null("RightArm/Weapon")
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

const max_distance: float = 40.0
const min_time_scale: float = 0.5

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
	
	if closest_drop.item in weapon.weapons.keys():
		M.C.mobile.set_super_button_text("pick up")
	
	if closest_drop.item in weapon.weapons.keys() and Input.is_action_just_pressed("pickup"):
		weapon.add_item(closest_drop.item, closest_drop.lvl)
		closest_drop.queue_free()
	
	elif !M.E.ground.item_spawner.items[closest_drop.item].get("weapon"):
		if closest_drop.item == "meat":
			M.E.dino.receive_damage(-S["meat"]["heal"])
		
		if closest_drop.item == "coin":
			M.E.dino.spawn_text("+" + str(S["coin"]["value"]), Color.GOLD)
		
		play(S[closest_drop.item]["sound"])
		closest_drop.queue_free()
	
	
	var target_scale = remap(closest_distance, 0, max_distance, min_time_scale, 1.0)
	
	#M.E.camera.zoom = Vector2.ONE / abs(target_scale - target_scale*5)
	if closest_drop.item in weapon.weapons.keys():
		Engine.time_scale = clamp(target_scale, min_time_scale, 1.0)
