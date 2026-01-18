extends Control

@onready var j1 := $LeftJoystick
@onready var j2 := $RightJoystick
@onready var ldash := $RightJoystick/LDashButton
@onready var rdash := $RightJoystick/RDashButton
@onready var timer_clear_text := $TextClear


func set_super_button_text(txt: String) -> void:
	if OS.has_feature("mobile"):
		j2.get_node_or_null("SuperButton/Label").text = txt
		timer_clear_text.start()


func _on_text_clear_timeout() -> void:
	j2.get_node_or_null("SuperButton/Label").text = ""


func ready() -> void:
	
	if OS.has_feature("mobile"):
		j1.show()
		j2.show()
		ldash.show()
		rdash.show()
	else:
		j1.queue_free()
		j2.queue_free()
		ldash.queue_free()
		rdash.queue_free()
		timer_clear_text.queue_free()
