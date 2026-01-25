extends VBoxContainer

@onready var pc := get_parent().get_parent()

@export var item: String
@export var texture: CompressedTexture2D


func _ready() -> void:
	if item: $TextureButton/Label.text = item + ".exe"
	if texture: $TextureButton/TextureRect.texture = texture


func _on_texture_button_pressed() -> void:
	if item == "exit": pc.deactivate()
	
	if item == "shop":
		pc.show_shop()
