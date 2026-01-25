extends Node

@onready var M := $"/root/Main"

var coins := 0:
	set(value):
		coins = value
		$"../../CanvasLayer/CoinsLabel".text = str(value)


func load_stats() -> void:
	if M.S.disk.has("coins"):
		coins = M.S.disk.loadd("coins")


func save_stats() -> void:
	M.S.disk.save("coins", coins)
