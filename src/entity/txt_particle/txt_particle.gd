extends Node2D

@onready var label := $Label
var txt := ""
var color: Color = Color.WHITE

func _ready() -> void:
	label.text = txt
	label.modulate = color


func _physics_process(_delta: float) -> void:
	label.position.y -= 1
	label.modulate.a *= 0.991
	
	if label.modulate.a <= 0.8: queue_free()
