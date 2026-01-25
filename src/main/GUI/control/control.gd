extends Control

@onready var j1 := $LeftJoystick
@onready var j2 := $RightJoystick
@onready var ldash := $RightJoystick/LDashButton
@onready var rdash := $RightJoystick/RDashButton
@onready var timer_clear_text := $TextClear

var mobile := false


func _on_text_clear_timeout() -> void:
	j2.get_node_or_null("SuperButton/Label").text = ""


func onready(ifmobile: bool) -> void:
	mobile = ifmobile
	
	if mobile:
		j1.show()
		j2.show()
		ldash.show()
		rdash.show()
		$MenuButton.show()
	else:
		j1.queue_free()
		j2.queue_free()
		ldash.queue_free()
		rdash.queue_free()
		timer_clear_text.queue_free()
		$MenuButton.queue_free()
