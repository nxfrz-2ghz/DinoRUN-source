extends "res://src/weapon/weapon.gd"


const STRATEGIES := [
	"fire_if_on_line",
	"auto_aim",
]

@export var strategy: int = 0
@export var gun := ""
@export var lvl := 0

var ammo: float = 7.0


func _ready() -> void:
	if gun == "":
		var usable_weapons: Array
		for i in range(weapons.keys().size()):
			var i_name: String = weapons.keys()[i]
			if weapons[i_name]["can_use_mob"] == true:
				usable_weapons.append(i_name)
		add_item(usable_weapons[randi() % usable_weapons.size()], lvl)
	else:
		add_item(gun, lvl)
	
	ammo -= weapons[inventory[1]["name"]]["damage"]


func _physics_process(_delta: float) -> void:
	if STRATEGIES[strategy] == "fire_if_on_line":
		
		if M.E.dino.position.x - self.global_position.x > 0:
			self.scale.x = 1
		else:
			self.scale.x = -1
		
		if anim_player.current_animation == "shoot": return
		if !$Recharge.is_stopped(): return
		if (M.E.dino.position.y - self.global_position.y) < 30:
			shoot()
			ammo -= 1.0
			if ammo < 0:
				$Recharge.start()
	
	elif STRATEGIES[strategy] == "auto_aim":
		pass


func _on_recharge_timeout() -> void:
	ammo += 7.0
