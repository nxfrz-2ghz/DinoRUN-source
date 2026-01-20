extends "res://src/weapon/weapon.gd"


func _ready() -> void:
	add_item("pistol")
	add_item("base_sword")


func swap_items() -> void:
	
	if anim_player.is_playing(): return
	
	var buffer: Dictionary = inventory[1]
	inventory[1] = inventory[2]
	inventory[2] = buffer
	update_item()


	#func update()
	
	# GRAPHICAL INVENTORY UPDATER
	#var slot := [
	#	M.C.inv.get_node_or_null("MarginContainer/HBoxContainer/VBoxContainer/MainGun"),
	#	M.C.inv.get_node_or_null("MarginContainer/HBoxContainer/VBoxContainer/SecondGun"),
	#]
	#
	#if weapons_textures.has(inventory[1]["name"]): slot[0].texture = weapons_textures[inventory[1]["name"]].texture
	#else: slot[0].texture = null
	#if weapons_textures.has(inventory[2]["name"]): slot[1].texture = weapons_textures[inventory[2]["name"]].texture
	#else: slot[1].texture = null
	#
	#var text: String = current_weapon
	#text += "\ndmg: " + str(current_damage)
	#text += "\nlvl: " + str(inventory[1]["lvl"])
	#M.C.inv.get_node_or_null("MarginContainer/HBoxContainer/RichTextLabel").text = text


func shoot() -> void:
	if !M.E.dino.alive: return
	super()


func _on_melee_hitbox_attack_body_entered(body: Node2D) -> void:
	if body.name != "Dino": super(body)


func spawn_bullet(gun: String) -> void:
	
	# Тряска Камеры и Вспышка
	if !weapons[gun]["quiet"]:
		M.E.camera.add_trauma(weapons[gun]["damage"])
		$Spawner/PointLight2D.energy += float(weapons[gun]["power"]) / 1000 - $Spawner/PointLight2D.energy / 2
	
	super(gun)


func _physics_process(_delta: float) -> void:
	
	if Input.is_action_just_pressed("swap_button_click"):
		swap_items()
	
	if $Spawner/PointLight2D.energy > 0.0:
		$Spawner/PointLight2D.energy -= 0.1
