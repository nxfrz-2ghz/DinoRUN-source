extends "res://src/weapon/weapon.gd"


const STRATEGIES := [
	"fire_if_on_line",
	"auto_aim",
]

@export var strategy: int = 0
@export var gun := ""
@export var lvl := 0


func _ready() -> void:
	if gun == "":
		add_item(weapons_textures.keys()[randi() % weapons_textures.keys().size()], lvl)
	else:
		add_item(gun, lvl)


func _physics_process(_delta: float) -> void:
	
	if STRATEGIES[strategy] == "fire_if_on_line":
		if anim_player.current_animation == "shoot": return
		if (M.E.dino.position.y - self.global_position.y) < 30:
			if M.E.dino.position.x - self.global_position.x > 0:
				self.scale.x = 1
			else:
				self.scale.x = -1
			shoot()
	
	elif STRATEGIES[strategy] == "auto_aim":
		pass
