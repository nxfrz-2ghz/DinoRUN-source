extends VBoxContainer

@onready var pc := get_parent().get_parent()

@export var item: String
@export var texture: Texture2D


func _ready() -> void:
	if item: $TextureButton/Label.text = item + ".exe"
	if pc.ceni.get(item): $TextureButton/Label.text += pc.ceni[item]
	if texture: $TextureButton/TextureRect.texture = texture


func _on_texture_button_pressed() -> void:
	if item == "exit": pc.deactivate()
	
	if item == "shop":
		pc.show_shop()
	
	if pc.ceni.get(item):
		pc.M.S.disk.save("weapon", item)
		pc.M.S.upgrades.coins -= int(pc.ceni[item])
