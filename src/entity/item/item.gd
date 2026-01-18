extends RigidBody2D

@onready var M := $"/root/Main"

@onready var sprite := $Sprite2D
@onready var anim_sprite := $AnimatedSprite2D
@onready var light := $PointLight2D
@onready var label := $Label

@export var item: String = ""
@export var lvl: int = 0

@export var texture: CompressedTexture2D
@export var frames: SpriteFrames

@export var light_color: Color
@export var light_energy: float

var weapons_names: Array


func _ready() -> void:
	if texture: sprite.texture = texture
	
	if frames:
		anim_sprite.sprite_frames = frames
		anim_sprite.play("default")
	
	if light_color:
		light.color = light_color
		light.enabled = true
	
	if light_energy:
		light.energy = light_energy
		light.enabled = true


func _integrate_forces(state) -> void:
	var trans = state.transform
	trans.origin.x -= M.E.ground.speed * Engine.time_scale
	state.transform = trans


func _physics_process(_delta: float) -> void:
	
	if self.position.y > 1000:
		queue_free()
	
	if !weapons_names: weapons_names = M.E.dino.get_node_or_null("RightArm/Weapon").weapons.keys()
	
	if item in weapons_names:
		if self.global_position.distance_to(M.E.dino.global_position) < 70:
			if label.text == "":
				var text := item
				text += "\ndmg: " + str(M.E.dino.get_node_or_null("RightArm/Weapon").WEAPONS[item]["damage"])
				text += "\nlvl: " + str(lvl)
				label.text = text
		else:
			label.text = ""
