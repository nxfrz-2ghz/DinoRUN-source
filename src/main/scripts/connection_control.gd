extends Node

@onready var M := $"/root/Main"

const res := [
	"res://src/scene_light/scene_light.tscn",
	"res://src/ground/ground.tscn",
	"res://src/dino/dino.tscn",
]

const scripts := [
	"res://src/main/scripts/pick_up_controller/pick_up_controller.tscn",
	"res://src/main/scripts/time_controller/time_controller.tscn",
]


func connect_node(node: Node) -> void:
	if node.name == "Ground":
		M.E.ground = M.E.get_node_or_null("Ground")
	if node.name == "Dino":
		M.E.dino = M.E.get_node_or_null("Dino")


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
	$"../../CutScenes/CutScenes".play("start_game")
