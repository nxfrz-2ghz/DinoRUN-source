extends Node

@onready var M := $"/root/Main"

const PC_UI := "res://src/ui/pc_ui/pcui.tscn"

const res := [
	"res://src/scene_light/scene_light.tscn",
	"res://src/ground/ground.tscn",
	"res://src/dino/dino.tscn",
]

const scripts := [
	"res://src/main/scripts/pick_up_controller/pick_up_controller.tscn",
	"res://src/main/scripts/time_controller/time_controller.tscn",
	"res://src/main/scripts/settings/settings.tscn",
]


func connect_node(node: Node) -> void:
	if node.name == "Ground":
		M.E.ground = M.E.get_node_or_null("Ground")
	if node.name == "Dino":
		M.E.dino = M.E.get_node_or_null("Dino")
	
	if node.name == "TimeController":
		M.S.time_controller = M.S.get_node_or_null("TimeController")
	if node.name == "Settings":
		M.S.settings = M.S.get_node_or_null("Settings")


func start() -> void:
	
	# Loading RES
	for i in range(res.size()):
		var pak: PackedScene = load(res[i])
		var node: Node = pak.instantiate()
		M.E.add_child(node)
		connect_node(node)
	
	# Loading SCRIPTS
	for i in range(scripts.size()):
		var pak: PackedScene = load(scripts[i])
		var node: Node = pak.instantiate()
		M.S.add_child(node)
		connect_node(node)
	
	M.game = true
	if !M.home:
		M.cutscenes.play("start_game")
	else:
		M.E.dino.alive = true
		M.C.menu.audio_player.get_node_or_null("AudioStreamPlayer").play_music("home")
		M.C.screen_text.add_message("HOME")
		M.C.mobile.onready(M.mobile)
		M.S.time_controller.queue_free()
		M.E.get_node("SceneLight").queue_free()
		M.C.way_bar.queue_free()
		M.C.hp_bar.visible = false
		
		var pcui: Control = load(PC_UI).instantiate()
		pcui.visible = false
		M.C.add_child(pcui)
