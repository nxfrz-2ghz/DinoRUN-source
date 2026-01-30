extends "res://src/ui/pbar_example/p_bar.gd"

@onready var icons_container := $IconsContainer
@onready var acs_container := $"../AcsContainer"

const effect_textures := {
	"poison": preload("res://res/sprites/icons/effects/poison_debuf.png"),
	"fire": preload("res://res/sprites/particles/fire_particle.png"),
}

const ICON := preload("res://src/ui/hp_bar/effect_icon.tscn")


func add_effect(texture_name) -> void:
	var icon: TextureRect = ICON.instantiate()
	icon.name = texture_name
	icon.texture = effect_textures[texture_name]
	icons_container.add_child(icon)


func add_acs(texture_name, texture: Texture2D) -> void:
	var icon: TextureRect = ICON.instantiate()
	icon.name = texture_name
	icon.texture = texture
	acs_container.add_child(icon)


func remove_effect(texture_name) -> void:
	icons_container.get_node(texture_name).queue_free()
