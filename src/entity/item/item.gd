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
var acs_names: Array


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
	if !M.game: return
	
	var trans = state.transform
	trans.origin.x -= M.E.ground.speed * Engine.time_scale
	state.transform = trans


func _physics_process(_delta: float) -> void:
	if !M.game: return
	
	if self.position.y > 1000:
		queue_free()
	
	if !weapons_names: weapons_names = M.E.ground.item_spawner.items["weapons"].keys()
	if !acs_names: acs_names = M.E.ground.item_spawner.items["acessories"].keys()
	
	if item == "PC":
		if self.global_position.distance_to(M.E.dino.global_position) < 50:
			if label.text == "":
				var text := "[PRESS 'C' TO USE]"
				label.text = text
		else:
			label.text = ""
	
	elif item in weapons_names:
		if self.global_position.distance_to(M.E.dino.global_position) < 70:
			if label.text == "":
				var text := ""
				if !M.mobile: text += "[PRESS 'C' TO PICKUP]\n"
				for child in get_children():
					if child.name == "cage":
						text += "PRICE 1000\n"
				text += item
				text += "\ndmg: " + str(M.E.dino.arm.weapon.weapons[item]["damage"])
				text += "\nlvl: " + str(lvl)
				label.text = text
		else:
			label.text = ""
	
	elif item in acs_names:
		if self.global_position.distance_to(M.E.dino.global_position) < 70:
			if label.text == "":
				var text := ""
				#print acs name
				label.text = text
		else:
			label.text = ""
