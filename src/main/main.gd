extends Node

@onready var S := $Scripts
@onready var E := $Environment
@onready var C := $CanvasLayer

var game := false
var screen: Vector2 = DisplayServer.window_get_size() / (DisplayServer.window_get_size() / Vector2i(640, 320))


func _ready() -> void:
	S.connection.start()
