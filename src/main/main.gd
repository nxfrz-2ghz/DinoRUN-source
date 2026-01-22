extends Node

@onready var S := $Scripts
@onready var E := $Environment
@onready var C := $CanvasLayer
@onready var cutscenes := $CutScenes/CutScenes

var game := false
var home := false
var screen: Vector2 = DisplayServer.window_get_size() / (DisplayServer.window_get_size() / Vector2i(640, 320))
var mobile := false


func _ready() -> void:
	if S.disk.has("home"):
		home = S.disk.loadd("home")
	
	if OS.has_feature("web_android") or OS.has_feature("web_ios") or OS.has_feature("mobile"):
		mobile = true
	
	S.connection.start()
	S.upgrades.load_stats()


func toogle_game_mode(on: bool) -> void:
	C.menu.visible = !on
	game = on
	C.hud.visible = on


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ESC") and !cutscenes.is_playing():
		if C.menu.visible:
			toogle_game_mode(true)
			# Return autoscroll speed
			E.ground.speed = E.ground.speed
		else:
			toogle_game_mode(false)
			E.ground.blayer_1.autoscroll.x = 0
			E.ground.blayer_2.autoscroll.x = 0
			E.ground.sky.autoscroll.x = 0
