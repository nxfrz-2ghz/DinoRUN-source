extends "res://src/entity/mob/mob.gd"

const ITEM := preload("res://src/entity/item/item.tscn")
var drop: String


func _ready() -> void:
	super()
	anim_sprite.frame = randi_range(0, 5)
	
	if !M.game: return
	var all_items: Array = M.E.ground.item_spawner.items["acessories"].keys() + M.E.ground.item_spawner.items["weapons"].keys()
	drop = all_items[randi() % all_items.size()]


func despawn() -> void:
	var item: RigidBody2D = ITEM.instantiate()
	var item_data: Dictionary
	if M.E.ground.item_spawner.items["consumables"].get(drop):
		item_data = M.E.ground.item_spawner.items["consumables"][drop]
	elif M.E.ground.item_spawner.items["weapons"].get(drop):
		item_data = M.E.ground.item_spawner.items["weapons"][drop]
	item.item = drop
	if item_data.get("texture"):
		item.texture = item_data["texture"]
	if item_data.get("frames"):
		item.frames = item_data["frames"]
	if item_data.get("light_color"):
		item.light_color = item_data["light_color"]
	if item_data.get("light_energy"):
		item.light_energy = item_data["light_energy"]
	
	item.lvl = M.E.ground.location + 2
	M.E.add_child(item)
	item.top_level = true
	item.position = self.global_position
	
	super()


func _physics_process(delta: float) -> void:
	if !alive: queue_free()
	self.position.x -= M.E.ground.speed * Engine.time_scale	
	super(delta)
	move_and_slide()
