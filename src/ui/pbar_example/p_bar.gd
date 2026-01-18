extends MarginContainer

@onready var pbar := $ProgressBar as ProgressBar
@onready var label := $RichTextLabel

@export var speed: float = 0.1 # Скорость анимации


var progress: float:
	set(value):
		progress = value
		pbar.material.set_shader_parameter("progress", value)

var progress_tail: float:
	set(value):
		progress_tail = value
		pbar.material.set_shader_parameter("progress_tail", value)

var current_value: float
var need_update := true


func _ready() -> void:
	progress = pbar.material.get_shader_parameter("progress")
	progress_tail = pbar.material.get_shader_parameter("progress_tail")
	set_value(1.0)


func set_value(value: float) -> void:
	current_value = value
	if current_value < progress:
		progress = current_value
	label.text = "[wave] " + str(int(current_value * 100)) + "%"
	need_update = true


func _physics_process(_delta: float) -> void:
	if need_update:
		
		# Остановка анимации если все готово 
		if current_value == progress and current_value == progress_tail: need_update = false 
		
		# Основная линия и хвост вместе с ней плавно заполняется при увеличении прогресса 
		if current_value > progress:
			progress += speed * ((current_value - progress) / 2)
			progress_tail = progress 
		
		# Хвост плавно догоняет линию прогресса, если прогресс уменьшили 
		if progress < progress_tail:
			progress_tail -= speed * ((progress_tail - progress) / 2)
