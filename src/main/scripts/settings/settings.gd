extends Node

@onready var M := $"/root/Main"

const RTX := "res://src/RTX/rtx.tscn"


func _ready() -> void:
	loadd()


func apply() -> void:
	AudioServer.set_bus_volume_db(1, linear_to_db(M.C.menu.music_scroll.value / 100))
	AudioServer.set_bus_volume_db(2, linear_to_db(M.C.menu.sound_scroll.value / 100))
	if M.C.menu.rtx_check.button_pressed: M.E.add_child(load(RTX).instantiate())


func loadd() -> void:
	if M.S.disk.loadd("music_volume"): M.C.menu.music_scroll.value = M.S.disk.loadd("music_volume")
	if M.S.disk.loadd("sound_volume"): M.C.menu.sound_scroll.value = M.S.disk.loadd("sound_volume")
	if M.S.disk.loadd("RTX_active"): M.C.menu.rtx_check.button_pressed = M.S.disk.loadd("RTX_active")
	
	apply()


func save() -> void:
	M.S.disk.save("music_volume", M.C.menu.music_scroll.value)
	M.S.disk.save("sound_volume", M.C.menu.sound_scroll.value)
	M.S.disk.save("RTX_active", M.C.menu.rtx_check.button_pressed)
	
	if M.C.menu.reset_check.pressed:
		M.S.disk.rm_dir("user://")
