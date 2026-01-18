extends Camera2D

var trauma = 0.0
var trauma_decay = 2.0 # Уменьшается на 2.0 в секунду
var intensity = 10.0   # Максимальное смещение (пиксели)

func _process(delta) -> void:
	# Уменьшаем травму со временем
	trauma = max(0.0, trauma - trauma_decay * delta)

	if trauma > 0:
		# Случайное смещение, зависящее от травмы
		offset = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * trauma * intensity
	else:
		offset = Vector2.ZERO

	# Применяем смещение к offset камеры, чтобы не менять ее основную позицию
	self.offset = offset


func add_trauma(amount) -> void:
	trauma = min(1.0, trauma + amount)
