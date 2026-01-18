extends Control

@onready var label: RichTextLabel = $RichTextLabel
@onready var timer: Timer = $Timer

var messages: Array = []

func add_message(txt: String) -> void:
	if messages.size() and messages[messages.size()-1] == txt:
		return
	messages.append(txt)
	if timer.is_stopped():
		print_msg()


func print_msg() -> void:
	if messages.is_empty():
		label.text = ""
		return
		
	label.text = "[pulse]"
	var msg: String = messages[0]
	var len_msg := len(msg)
	if len_msg == 0:
		timer.start()
		return

	for ch in msg:
		await get_tree().create_timer(1.0 / len_msg).timeout
		label.text += ch
	
	timer.start()


func _on_timer_timeout() -> void:
	if messages.is_empty():
		timer.stop()
		return

	messages.remove_at(0)
	while label.modulate.a > 0:
		await get_tree().process_frame
		label.modulate.a -= 0.01
	label.modulate.a = 1.0
	
	print_msg()
