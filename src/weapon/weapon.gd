extends Node2D

@onready var M := $"/root/Main"

@onready var audio_player := $Audio/AudioStreamPlayer
@onready var anim_player := $AnimationPlayer
@onready var spawner := $Spawner


@onready var weapons_textures := {
	"pistol" : $Sprites/Pistol,
	"shotgun" : $Sprites/Shotgun,
	"P90" : $Sprites/P90,
	"M4" : $Sprites/M4,
	"rocket_launcher" : $Sprites/RocketLauncher,
	"sniper_rifle" : $Sprites/SniperRifle,
	"toxic_gun" : $Sprites/ToxicGun,
	"fire_torch" : $Sprites/FireTorch,
	"base_sword" : $Sprites/BaseSword,
}


const BULLET := preload("res://src/entity/bullet/bullet.tscn")

const weapons := {
	"pistol": {
		"damage": 0.4,
		"power": 1000,
		"speed": 2,
		"spread_deg": 2.0,
		"sound": preload("res://res/sounds/weapons/gun/gun shot.mp3"),
		"quiet": false,
		"can_use_mob": true,
	},
	"shotgun": {
		"damage": 0.8,
		"power": 900,
		"speed": 0.3,
		"spread_deg": 12.0,
		"sound": preload("res://res/sounds/weapons/shotgun/shotgun shot.mp3"),
		"quiet": false,
		"can_use_mob": true,
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
		"can_use_mob": true,
	},
	"M4": {
		"damage": 0.3,
		"power": 1200,
		"speed": 4,
		"spread_deg": 3.0,
		"sound": preload("res://res/sounds/weapons/gun/gun shot.mp3"),
		"quiet": false,
		"can_use_mob": true,
	},
	"rocket_launcher": {
		"damage": 2.0,
		"power": 100,
		"speed": 0.5,
		"sound": preload("res://res/sounds/weapons/rocket_launcher/rl_launch.mp3"),
		"quiet": false,
		"can_use_mob": false,
		"knockback": 100,
		"custom_bullet": preload("res://src/entity/rocket/rocket.tscn"),
	},
	"sniper_rifle": {
		"damage": 5.0,
		"power": 1200,
		"speed": 0.5,
		"spread_deg": 0.2,
		"sound": preload("res://res/sounds/weapons/plasma_rifle/plasma_rifle_shot.mp3"),
		"quiet": false,
		"can_use_mob": true,
	},
	"toxic_gun": {
		"damage": 0.1,
		"power": 800,
		"speed": 10,
		"spread_deg": 0,
		"sound": null,
		"quiet": true,
		"can_use_mob": true,
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
		"bullet_texture": preload("res://res/sprites/entity/poison_bullet/poison_bullet.png"),
	},
	"fire_torch": {
		"damage": 1.2,
		"speed": 0.6,
		"sound": null,
		"can_use_mob": false,
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
	"base_sword": {
		"damage": 1.2,
		"speed": 1,
		"sound": preload("res://res/sounds/weapons/sword/hit.mp3"),
		"can_use_mob": false,
	},
	"": {
		"speed": 0.0,
		"sound": null,
		"quiet": true,
		"can_use_mob": false,
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
	if inventory[1]["name"] == "": return
	var drop: RigidBody2D = M.E.ground.item_spawner.ITEM.instantiate()
	drop.item = inventory[1]["name"]
	drop.lvl = inventory[1]["lvl"]
	drop.texture = M.E.ground.item_spawner.items["weapons"][drop.item]["texture"]
	M.E.ground.item_spawner.add_child(drop)
	drop.top_level = true
	drop.position = self.global_position
	drop.apply_impulse(Vector2.RIGHT.rotated(self.global_rotation * 100))
	
	inventory[1]["name"] = ""
	inventory[1]["lvl"] = 0
	
	update_item()


func update_item() -> void:
	for w in weapons_textures.values():
		w.hide()
		weapons_textures["fire_torch"].get_node_or_null("Particles").emitting = false
	
	var current_weapon: String = inventory[1]["name"]
	if current_weapon != "" and current_weapon in weapons_textures:
		weapons_textures[current_weapon].show()
		if current_weapon == "fire_torch":
			weapons_textures["fire_torch"].get_node_or_null("Particles").emitting = true
	
	var info = weapons.get(current_weapon, weapons[""] )
	audio_player.stream = info.get("sound", weapons[""].get("sound"))
	anim_player.speed_scale = info.get("speed", 0)


func lvl_multiplier(num: float, lvl: int = inventory[1]["lvl"]) -> float:
	var weapon_levelups: int = 0
	if M.S.acs.acs.get("weapon_levelup") and get_parent().get_parent().name == "SkeletWithGun":
		weapon_levelups = M.S.acs.acs["weapon_levelup"]
	return (0.5 * num * (lvl + weapon_levelups))


func shoot() -> void:
	var weapon: String = inventory[1]["name"]
	
	if weapons[weapon].get("power"): # WEAPON IS GUN
		if anim_player.current_animation == "shoot": return
		
		if weapon == "shotgun":
			for i in range(weapons["shotgun"].get("bullets")):
				spawn_bullet(weapon)
		else:
			spawn_bullet(weapon)
		
		if weapons[weapon].get("knockback"):
			var knockback: int = weapons[weapon]["knockback"]
			knockback += floor(lvl_multiplier(knockback))
			get_parent().get_parent().velocity += Vector2.RIGHT.rotated(self.global_rotation) * -knockback
		
		anim_player.play("shoot")
		
		audio_player.pitch_scale = randf_range(0.8, 1.0)
		audio_player.play()
	
	else: # WEAPON IS MELEE
		if anim_player.current_animation != "melee_attack":
			anim_player.play("melee_attack")


func _on_melee_hitbox_attack_body_entered(body: Node2D) -> void: # OM MELEE ATTACK
	if anim_player.current_animation == "melee_attack":
		var weapon: String = inventory[1]["name"]
		if body.has_method("receive_damage") and weapons[weapon].get("damage"):
			body.receive_damage(weapons[weapon]["damage"])
			$Sprites/MeleeHitboxAttack/CollisionShape2D.set_deferred("disabled", true)
			audio_player.pitch_scale = randf_range(0.8, 1.0)
			audio_player.play()
		if body.has_method("receive_effects") and weapons[weapon].get("effects"):
			body.receive_effects(weapons[weapon]["effects"])
			$Sprites/MeleeHitboxAttack/CollisionShape2D.set_deferred("disabled", true)
			audio_player.pitch_scale = randf_range(0.8, 1.0)
			audio_player.play()


func spawn_bullet(gun: String) -> void:
	
	# Спавн пули
	if weapons[gun].get("custom_bullet"):
		var bullet: RigidBody2D = weapons[gun]["custom_bullet"].instantiate()
		M.E.add_child(bullet)
		bullet.position = spawner.global_position
		bullet.rotation = spawner.global_rotation
		bullet.apply_impulse(Vector2.RIGHT.rotated(bullet.rotation) * weapons[gun]["power"])
		bullet.damage = weapons[gun]["damage"] + lvl_multiplier(weapons[gun]["damage"])
		return
	
	var bullet: RigidBody2D = BULLET.instantiate()
	M.E.add_child(bullet)
	bullet.position = spawner.global_position
	
	var spread := deg_to_rad(weapons[gun]["spread_deg"])
	bullet.rotation = spawner.global_rotation + randf_range(-spread * 0.5, spread * 0.5)
	bullet.screen_speed = -M.E.ground.speed
	bullet.apply_impulse(Vector2.RIGHT.rotated(bullet.rotation) * weapons[gun]["power"])
	bullet.damage = weapons[gun]["damage"] + lvl_multiplier(weapons[gun]["damage"])
	
	if weapons[gun].get("despawn_delay"):
		bullet.despawn_delay = weapons[gun]["despawn_delay"]
	if weapons[gun].get("effects"):
		bullet.effects = weapons[gun]["effects"]
	if weapons[gun].get("bullet_texture"):
		bullet.get_node_or_null("Sprite2D").texture = weapons[gun]["bullet_texture"]
