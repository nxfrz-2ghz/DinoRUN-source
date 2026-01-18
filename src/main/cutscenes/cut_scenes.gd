extends AnimationPlayer

@onready var M := $"/root/Main"

const txt_particle := preload("res://src/entity/txt_particle/txt_particle.tscn")

@export var run_speed: float:
	set(value):
		run_speed = value
		M.E.ground.speed = value
		if value > 0:
			M.E.dino.anim_sprite.play("run")
	get:
		return run_speed


func dino_scream() -> void:
	M.E.dino.velocity = Vector2(0, -200)
	for i in range(20):
		var n: Node2D = add_text_particle("!")
		n.position += Vector2(randf()-0.5, -randf()) * 50


func add_text_particle(text: String) -> Node2D:
	var n := txt_particle.instantiate()
	n.txt = text
	M.E.add_child(n)
	n.position = M.E.dino.position
	return n


func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "start_game":
		M.E.dino.alive = true
		M.C.screen_text.add_message("RUN!")
