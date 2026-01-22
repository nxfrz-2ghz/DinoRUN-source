extends Node

@onready var light := $"../../Environment/SceneLight/Sun"
@onready var night_sky := $"../../Environment/Ground/Layers/NightSky/Sprite2D"

const night_sky_textures := [
	preload("res://res/sprites/world/night_sky/1.png"),
	preload("res://res/sprites/world/night_sky/2.png"),
	preload("res://res/sprites/world/night_sky/3.png"),
	preload("res://res/sprites/world/night_sky/4.png"),
	preload("res://res/sprites/world/night_sky/5.png"),
]

const linear_speed := 1000
const rotate_speed := 100
const night_speed_up := 4

@export var speed := 0.01

var last_sun_pos: float = 0


func is_night() -> bool:
	if night_sky.modulate.a == 0:
		return false
	return true


func _ready() -> void:
	sky_update()


func sky_update() -> void:
	if last_sun_pos <= 0 and light.position.y > 0: # ЕСЛИ ПРОШЕЛ ОДИН ЦИКЛ ДЕНЬ-НОЧЬ
		night_sky.texture = night_sky_textures[randi_range(0, night_sky_textures.size()-1)]
	night_sky.modulate.a = clamp(0, (light.position.y - 640)/100, 255)


func _physics_process(delta: float) -> void:
	last_sun_pos = light.position.y
	light.position += light.transform.x * linear_speed * delta * speed
	light.rotation += deg_to_rad(rotate_speed * delta * speed)
	
	sky_update()
	
	# Ночь слишком длинная поэтому она ускоряется
	if light.position.y > 320:
		for i in range(night_speed_up):
			light.position += light.transform.x * linear_speed * delta * speed
			light.rotation += deg_to_rad(rotate_speed * delta * speed)
