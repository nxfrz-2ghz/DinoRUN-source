extends Area2D

@onready var dino := get_parent()

# УРОН ОТ РАЗГОНА ПРИ СТОЛКНОВЕНИИ
func _on_body_entered(body: Node2D) -> void:
	
	# РАСЧЕТ УРОНА
	var damage: float = abs(dino.velocity.x) + abs(dino.velocity.y)
	if body is CharacterBody2D:
		# СЛОЖЕНИЕ СКОРОСТЕЙ ТЕЛ.x
		if abs(dino.velocity.x + body.velocity.x) == abs(dino.velocity.x) + abs(body.velocity.x): # ЕСЛИ НАПРАВЛЕНИЕ ОДИНАКОВОЕ
			damage -= abs(dino.velocity.x)
		else: # ЕСЛИ НАПРАВЛЕНИЕ ТЕЛ РАЗНОЕ, ЗНАЧИТ ОНИ НАПРАВЛЕНЫ ДРУГ НА ДРУГА И СКОРОСТЬ СКЛАДЫВАЕТСЯ
			damage += abs(dino.velocity.x)
		
		# СЛОЖЕНИЕ СКОРОСТЕЙ ТЕЛ.y
		if abs(dino.velocity.y + body.velocity.y) == abs(dino.velocity.y) + abs(body.velocity.y): # ЕСЛИ НАПРАВЛЕНИЕ ОДИНАКОВОЕ
			damage -= abs(dino.velocity.y)
		else: # ЕСЛИ НАПРАВЛЕНИЕ ТЕЛ РАЗНОЕ, ЗНАЧИТ ОНИ НАПРАВЛЕНЫ ДРУГ НА ДРУГА И СКОРОСТЬ СКЛАДЫВАЕТСЯ
			damage += abs(dino.velocity.y)
		
		body.velocity += dino.velocity / 2
	
	damage = snapped(damage / 1000, 0.1)
	
	# НАНЕСЕНИЕ УРОНА
	if body.has_method("receive_damage") and body.name != dino.name and damage > 0.1:
		body.receive_damage(damage)
		$AudioStreamPlayer.play()
