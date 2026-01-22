extends PanelContainer

@onready var M := $"/root/Main"

@onready var music_scroll := $MarginContainer/HBoxContainer/VBoxContainer/PanelContainer/MarginContainer/VBoxContainer/HSlider
@onready var sound_scroll := $MarginContainer/HBoxContainer/VBoxContainer/PanelContainer3/MarginContainer/VBoxContainer/HSlider
@onready var rtx_check := $MarginContainer/HBoxContainer/VBoxContainer/PanelContainer2/MarginContainer/CheckBox
@onready var reset_check := $MarginContainer/HBoxContainer/VBoxContainer/PanelContainer4/MarginContainer/CheckBox

var cheat: Array
var cheat_activated := false


func check_cheatcode():
	if cheat.size() > 8:
		cheat.pop_front()
	if cheat == ["w","s","w","s","a","d","a","d"]:
		cheat_activated = true
		print("stupid cheater!")
		$RichTextLabel2.modulate.a = 255
		$RichTextLabel2.text = "[wave][rainbow]CHEATS ACTIVATED"


func _input(_event: InputEvent) -> void:
	if self.visible:
		if Input.is_action_just_pressed("ui_up"):
			cheat.append("w")
			check_cheatcode()
		if Input.is_action_just_pressed("ui_down"):
			cheat.append("s")
			check_cheatcode()
		if Input.is_action_just_pressed("ui_left"):
			cheat.append("a")
			check_cheatcode()
		if Input.is_action_just_pressed("ui_right"):
			cheat.append("d")
			check_cheatcode()


func _on_check_box_toggled(toggled_on: bool) -> void:
	if toggled_on:
		rtx_check.text = "RTX ON"
	else:
		rtx_check.text = "RTX OFF"


func _on_continue_button_pressed() -> void:
	M.S.settings.save()
	M.toogle_game_mode(true)


func _on_restart_button_pressed() -> void:
	M.S.settings.save()
	M.S.upgrades.save_stats()
	get_tree().reload_current_scene()


func _on_exit_button_pressed() -> void:
	M.S.settings.save()
	M.S.upgrades.save_stats()
	get_tree().quit()
