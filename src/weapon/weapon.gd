extends Node2D

@onready var M := $"/root/Main"

@onready var audio_player := $AudioStreamPlayer
@onready var anim_player := $AnimationPlayer
@onready var spawner := $Spawner
@onready var melee_attack_cooldown := $CDMeleeAttack

@onready var weapons := {
	"pistol" : $Sprites/Pistol,
	"shotgun" : $Sprites/Shotgun,
	"P90" : $Sprites/P90,
	"M4" : $Sprites/M4,
	"rocket_launcher" : $Sprites/RocketLauncher,
	"sniper_rifle" : $Sprites/SniperRifle,
	"toxic_gun" : $Sprites/ToxicGun,
	"fire_torch" : $Sprites/FireTorch,
}



const BULLET := preload("res://src/entity/bullet/bullet.tscn")

const WEAPONS := {
	"pistol": {
		"damage": 0.4,
		"power": 1000,
		"speed": 2,
		"spread_deg": 2.0,
		"sound": preload("res://res/sounds/weapons/gun/gun shot.mp3"),
		"quiet": false,
	},
	"shotgun": {
		"damage": 0.8,
		"power": 900,
		"speed": 0.3,
		"spread_deg": 12.0,
		"sound": preload("res://res/sounds/weapons/shotgun/shotgun shot.mp3"),
		"quiet": false,
		"bullets": 6,
		"knockback": 500,
	},
	"P90": {
		"damage": 0.2,
		"power": 1200,
		"speed": 6,
		"spread_deg": 4.0,
		"sound": preload("res://res/sounds/weapons/gun/gun shot.mp3"),
		"quiet": false,
	},
	"M4": {
		"damage": 0.3,
		"power": 1200,
		"speed": 4,
		"spread_deg": 3.0,
		"sound": preload("res://res/sounds/weapons/gun/gun shot.mp3"),
		"quiet": false,
	},
	"rocket_launcher": {
		"damage": 5,
		"power": 500,
		"speed": 0.2,
		"spread_deg": 1.0,
		"sound": preload("res://res/sounds/weapons/gun/gun shot.mp3"),
		"quiet": true,
		"knockback": 100,
	},
	"sniper_rifle": {
		"damage": 5,
		"power": 1200,
		"speed": 0.5,
		"spread_deg": 0.2,
		"sound": preload("res://res/sounds/weapons/plasma_rifle/plasma_rifle_shot.mp3"),
		"quiet": false,
	},
	"toxic_gun": {
		"damage": 0.1,
		"power": 800,
		"speed": 10,
		"spread_deg": 0,
		"sound": null,
		"quiet": true,
		"effects":
		{
			"poison":
			{
				"damage": 0.1,
				"delay": 0.5,
				"time": 3.0,
			},
		},
		"despawn_delay": 20.0,
		"bullet_texture": preload("res://res/sprites/entity/poison_bullet/bullet.png")
	},
	"fire_torch": {
		"cooldown": 0.5,
		"damage": 1.2,
		"speed": 1,
		"sound": null,
		"effects":
		{
			"fire":
			{
				"damage": 0.5,
				"delay": 1,
				"time": 3.0,
			},
		},
	},
	"": {
		"speed": 0.0,
		"sound": null,
		"quiet": true,
	},
}

var inventory := {
	1: {
		"name": "",
		"lvl": 0,
	},
	2: {
		"name": "",
		"lvl": 0,
	},
} 


var rng := RandomNumberGenerator.new()


func _ready() -> void:
	rng.randomize()
	add_item("pistol")
	add_item("fire_torch")


func add_item(item_name: String, lvl: int = 0) -> void:
	
	var dict := {
		"name": item_name,
		"lvl": lvl,
	} 
	
	if inventory[1]["name"] == "":
		inventory[1] = dict
	elif inventory[2]["name"] == "":
		inventory[2] = dict
	else:
		drop_item()
		inventory[1] = dict
	update_item()


func drop_item() -> void:
	var drop: RigidBody2D = M.E.ground.item_spawner.ITEM.instantiate()
	drop.item = inventory[1]["name"]
	drop.lvl = inventory[1]["lvl"]
	drop.texture = M.E.ground.item_spawner.items[inventory[1]["name"]]["texture"]
	M.E.ground.item_spawner.add_child(drop)
	drop.top_level = true
	drop.position = self.global_position
	drop.apply_impulse(Vector2.RIGHT.rotated(self.global_rotation * 100))
	
	inventory[1]["name"] = ""
	inventory[1]["lvl"] = 0
	
	update_item()


func swap_items() -> void:
	
	if anim_player.is_playing(): return
	
	var buffer: Dictionary = inventory[1]
	inventory[1] = inventory[2]
	inventory[2] = buffer
	update_item()


func update_item() -> void:
	for w in weapons.values():
		w.hide()
		weapons["fire_torch"].get_node_or_null("Particles").emitting = true

	var current_weapon: String = inventory[1]["name"]
	if current_weapon != "" and current_weapon in weapons:
		weapons[current_weapon].show()
		if current_weapon == "fire_torch":
			weapons["fire_torch"].get_node_or_null("Particles").emitting = true
	var info = WEAPONS.get(current_weapon, WEAPONS[""] )
	audio_player.stream = info.get("sound", WEAPONS[""].get("sound"))
	anim_player.speed_scale = info.get("speed", 0)
	
	
	# GRAPHICAL INVENTORY UPDATER
	#var slot := [
	#	M.C.inv.get_node_or_null("MarginContainer/HBoxContainer/VBoxContainer/MainGun"),
	#	M.C.inv.get_node_or_null("MarginContainer/HBoxContainer/VBoxContainer/SecondGun"),
	#]
	#
	#if weapons.has(inventory[1]["name"]): slot[0].texture = weapons[inventory[1]["name"]].texture
	#else: slot[0].texture = null
	#if weapons.has(inventory[2]["name"]): slot[1].texture = weapons[inventory[2]["name"]].texture
	#else: slot[1].texture = null
	#
	#var text: String = current_weapon
	#text += "\ndmg: " + str(current_damage)
	#text += "\nlvl: " + str(inventory[1]["lvl"])
	#M.C.inv.get_node_or_null("MarginContainer/HBoxContainer/RichTextLabel").text = text


func lvl_multiplier(num: float) -> float:
	return (0.5 * (num * inventory[1]["lvl"]))


func shoot() -> void:
	if !M.E.dino.alive: return
	var weapon: String = inventory[1]["name"]
	
	if WEAPONS[weapon].get("power"): # WEAPON IS GUN
		if anim_player.current_animation == "shoot": return
		
		if weapon == "shotgun":
			for i in range(WEAPONS["shotgun"].get("bullets")):
				spawn_bullet(weapon)
		else:
			spawn_bullet(weapon)
		
		if WEAPONS[weapon].get("knockback"):
			var knockback: int = WEAPONS[weapon]["knockback"]
			knockback += floor(lvl_multiplier(knockback))
			M.E.dino.velocity += Vector2.RIGHT.rotated(self.global_rotation) * -knockback
		
		anim_player.play("shoot")
		
		audio_player.pitch_scale = randf_range(0.8, 1.0)
		audio_player.play()
	
	else: # WEAPON IS MELEE
		if melee_attack_cooldown.is_stopped():
			anim_player.play("melee_attack")


func _on_melee_hitbox_attack_body_entered(body: Node2D) -> void: # OM MELEE ATTACK
	if anim_player.current_animation == "melee_attack":
		if body.name == "Dino": return
		var weapon: String = inventory[1]["name"]
		if body.has_method("receive_damage") and WEAPONS[weapon].get("damage"):
			body.receive_damage(WEAPONS[weapon]["damage"])
			melee_attack_cooldown.wait_time = WEAPONS[weapon]["cooldown"]
			melee_attack_cooldown.start()
			anim_player.play("RESET")
		if body.has_method("receive_effects") and WEAPONS[weapon].get("effects"):
			body.receive_effects(WEAPONS[weapon]["effects"])
			melee_attack_cooldown.wait_time = WEAPONS[weapon]["cooldown"]
			melee_attack_cooldown.start()
			anim_player.play("RESET")


func spawn_bullet(gun: String) -> void:
	
	# Тряска Камеры и Вспышка
	if !WEAPONS[gun]["quiet"]:
		M.E.camera.add_trauma(WEAPONS[gun]["damage"])
		$Spawner/PointLight2D.energy += float(WEAPONS[gun]["power"]) / 1000 - $Spawner/PointLight2D.energy / 2
	
	# Спавн пули
	var bullet: RigidBody2D = BULLET.instantiate()
	M.E.add_child(bullet)
	bullet.position = spawner.global_position
	
	var spread := deg_to_rad(WEAPONS[gun]["spread_deg"])
	bullet.rotation = spawner.global_rotation + rng.randf_range(-spread * 0.5, spread * 0.5)
	bullet.screen_speed = -M.E.ground.speed
	bullet.apply_impulse(Vector2.RIGHT.rotated(bullet.rotation) * WEAPONS[gun]["power"])
	bullet.damage = WEAPONS[gun]["damage"] + lvl_multiplier(WEAPONS[gun]["damage"])
	
	if WEAPONS[gun].get("despawn_delay"):
		bullet.despawn_delay = WEAPONS[gun]["despawn_delay"]
	if WEAPONS[gun].get("effects"):
		bullet.effects = WEAPONS[gun]["effects"]
	if WEAPONS[gun].get("bullet_texture"):
		bullet.get_node_or_null("Sprite2D").texture = WEAPONS[gun]["bullet_texture"]


func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("swap_button_click"):
		swap_items()
	
	if $Spawner/PointLight2D.energy > 0.0:
		$Spawner/PointLight2D.energy -= 0.1
