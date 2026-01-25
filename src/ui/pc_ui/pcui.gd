extends Control

@onready var M := $"/root/Main"
@onready var icons_container := $IconsContainer

const ICON := preload("res://src/ui/pc_ui/icon/icon.tscn")
const icon_textures := {
	"exit" : preload("res://res/sprites/world/pc/shutdown.png"),
	"researcher" : preload("res://res/sprites/world/pc/research_scheme.png"),
	"shop" : preload("res://res/sprites/world/pc/shop.png"),
}

var rng := RandomNumberGenerator.new()


func _ready() -> void:
	rng.seed = randi()


func add_icon(item: String, texture = icon_textures.get(item)):
	var icon := ICON.instantiate()
	icon.name = item
	icon.item = item
	icon.texture = texture
	icons_container.add_child(icon)


func clear_icons() -> void:
	for child in icons_container.get_children():
		child.queue_free()


func activate():
	self.visible = true
	M.game = false
	
	add_icon("researcher")
	add_icon("shop")
	add_icon("exit")


func deactivate():
	self.visible = false
	M.game = true
	
	clear_icons()


func show_shop() -> void:
	clear_icons()
	
	var weapons = M.E.ground.item_spawner.items["weapons"].keys()
	for i in range(3):
		var item: String = weapons[rng.randi() % weapons.size()]
		
		if M.E.ground.item_spawner.items["weapons"][item].get("texture"):
			add_icon(item, M.E.ground.item_spawner.items["weapons"][item]["texture"])
		if M.E.ground.item_spawner.items["weapons"][item].get("frames"):
			add_icon(item, M.E.ground.item_spawner.items["weapons"][item]["frames"].get_frame_texture("default", 0))
	
	add_icon("exit")
