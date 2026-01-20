extends Node

@onready var S := $Scripts
@onready var E := $Environment
@onready var C := $CanvasLayer

var game := false
var screen: Vector2 = DisplayServer.window_get_size() / (DisplayServer.window_get_size() / Vector2i(640, 320))
var mobile := false


func _ready() -> void:
	
	if OS.has_feature("web_android") or OS.has_feature("web_ios") or OS.has_feature("mobile"):
		mobile = true
	
	S.connection.start()
