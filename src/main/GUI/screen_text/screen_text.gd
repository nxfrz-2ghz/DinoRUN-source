extends Control

@onready var label: RichTextLabel = $RichTextLabel

var messages: Array = []
var current_msg: String = ""
var char_timer: float = 0.0
var fade_out: bool = false

func add_message(txt: String) -> void:
	if not messages.is_empty() and messages.back() == txt:
		return
	messages.append(txt)
	if current_msg == "":
		next_message()

func next_message() -> void:
	if messages.is_empty():
		current_msg = ""
		label.text = ""
		return
		
	current_msg = messages.pop_front()
	label.text = "[pulse]" + current_msg
	label.visible_characters = 0
	label.modulate.a = 1.0
	char_timer = 0.0
	fade_out = false

func _process(delta: float) -> void:
	if current_msg == "":
		return

	# Логика появления символов
	if label.visible_ratio < 1.0:
		char_timer += delta
		var speed = 1.0 / max(len(current_msg), 1)
		if char_timer >= speed:
			label.visible_characters += 1
			char_timer = 0.0
	# Логика исчезновения после написания
	else:
		char_timer += delta
		if char_timer >= 2.0: # Задержка перед исчезновением (аналог Timer)
			fade_out = true
		
		if fade_out:
			label.modulate.a -= delta # Плавное затухание
			if label.modulate.a <= 0:
				next_message()
