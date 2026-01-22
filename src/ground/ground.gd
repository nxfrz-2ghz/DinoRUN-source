extends Node2D

@onready var M := $"/root/Main"

@onready var home_location := $home_location

@onready var tile_0: TileMapLayer = $Tile_0
@onready var tile_1: TileMapLayer = $Tile_1

@onready var blayer_1: Parallax2D = $Layers/Layer_1
@onready var blayer_2: Parallax2D = $Layers/Layer_2
@onready var sky: Parallax2D = $Layers/NightSky

@onready var mob_spawner := $MobSpawner
@onready var item_spawner := $ItemSpawner

const locations := [
	"forest",
	"desert",
	"iceland",
	"nether",
]

const tiles := {
	"grass": {
		0: Vector2i(3, 0),
		
		# Тайлы для загругления краев
		1001: Vector2i(1, 1),
		1002: Vector2i(5, 1),
		
	},
	"dirt": {
		0: Vector2i(3, 1),
		1: Vector2i(3, 2),
		
		# Тайлы для загругления краев
		1001: Vector2i(1, 2),
		1002: Vector2i(5, 2),
	},
	"dirt_desert": {
		0: Vector2i(7, 20),
		1: Vector2i(7, 20),
		
		# Тайлы для загругления краев
		1001: Vector2i(1, 2),
		1002: Vector2i(5, 2),
	},
	"b_dirt": {
		0: Vector2i(13, 13),
		1: Vector2i(13, 14),
		
		# Тайлы для загругления краев
		1001: Vector2i(11, 14),
		1002: Vector2i(15, 14),
	},
}

const bg_sprites := {
	1:{
		"forest": preload("res://res/sprites/world/background/forest/layer_1.png"),
		"desert": preload("res://res/sprites/world/background/desert/layer_1.png"),
	},
	2:{
		"forest": preload("res://res/sprites/world/background/forest/layer_2.png"),
		"desert": preload("res://res/sprites/world/background/desert/layer_2.png"),
	},
}


@export var world_seed := randi()

# Procedural generation settings
@export var tile_size: int = 16
@export var base_row: int = 20 # tile row index of main ground (tweak if needed)
@export var max_additional_rows: int = 3
@export var platform_min_length: int = 5
@export var platform_max_length: int = 10
@export var platform_spacing: int = 4 # horizontal spacing between potential platforms
@export var vertical_row_spacing: int = 5 # vertical distance between platform rows

var noise: FastNoiseLite

const LOCATION_DISTANCE := 20
const start_offset := -300
const sprite_size_h := 640

var location: int = 0
var distance: int = 0
var speed: float = 0.0:
	set(value):
		blayer_1.autoscroll.x = -value / 2 * 60
		blayer_2.autoscroll.x = -value / 4 * 60
		sky.autoscroll.x = -value / 8 * 60
		speed = value
	get:
		return speed


func _ready() -> void:
	if M.home:
		tile_0.queue_free()
		tile_1.queue_free()
		mob_spawner.queue_free()
		item_spawner.queue_free()
		$AnimationPlayer.queue_free()
		$Layers.queue_free()
	else:
		M.S.disk.save("home", true)
		home_location.queue_free()
		
		tile_0.position.x = 0 + start_offset
		tile_1.position.x = M.screen.x + start_offset
		
		M.C.way_bar.max_value = M.screen.x * LOCATION_DISTANCE * 4
		
		
		# Setup noise
		noise = FastNoiseLite.new()
		noise.seed = int(world_seed)

		gen_location_tile(location, tile_0)
		gen_location_tile(location, tile_1)
		$AnimationPlayer.play("start")


func _set_location_to_blayers() -> void:
	var loc_name: String = locations[location]
	blayer_1.get_node_or_null("Sprite2D").texture = bg_sprites[1][loc_name]
	blayer_2.get_node_or_null("Sprite2D").texture = bg_sprites[2][loc_name]


func _print_location_name() -> void:
	M.C.screen_text.add_message("THE " + locations[location].to_upper())


func move_tile(tile: TileMapLayer) -> void:
	tile.position.x -= speed * Engine.time_scale
	
	if tile.position.x <= -M.screen.x:
		tile.position.x = M.screen.x
		gen_location_tile(location, tile)
		@warning_ignore("integer_division")
		for i in range(ceil(distance/10+location)+1):
			await get_tree().create_timer(0.1).timeout
			mob_spawner.spawn(world_seed, M.screen, location, distance, M.S.time_controller.is_night())
		distance += 1
		speed += 0.05
		
		if distance > LOCATION_DISTANCE:
			distance = 0
			location += 1
			$AnimationPlayer.play("change_location")


func gen_location_tile(loc: int, tile: TileMapLayer) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = loc + distance + world_seed

	tile.clear()
	
	if loc == 0:
		
		# Number of horizontal cells to fill (cover visible + a bit of buffer)
		@warning_ignore("integer_division")
		var cells_wide := int(ceil(M.screen.x / tile_size)) + 8

		# Generate base ground row and record how many extra rows allowed per column
		var allowed_heights := []
		for x in range(cells_wide):
			var gx := x + loc * cells_wide
			# smooth height from noise
			var n = noise.get_noise_1d(float(gx))
			# map noise [-1,1] to additional rows count
			var additional_rows := int(round(((n + 1.0) / 2.0) * max_additional_rows))
			allowed_heights.append(additional_rows)

			var ground_y := base_row
			# Place main base tile (dirt)
			# Use dirt tile id 0 from tiles mapping
			for i in range(5):
				tile.set_cell(Vector2i(x, ground_y + i), 0, tiles["dirt"][rng.randi_range(0,1)])

			# Place background b_dirt behind (optional layer): try to set at a higher/lower layer if available
			# background one row below main ground
			#tile.set_cell(Vector2i(x, ground_y - 1), 0, tiles["b_dirt"][0])
			
		# Additional floating platforms above base depending on noise
		# Generate platforms per-row so we can enforce horizontal spacing.
		# Use recorded allowed heights to decide where platforms may appear
		# If any column allows at least one extra row, attempt platform generation
		var max_allowed := 0
		for h in allowed_heights:
			if h > max_allowed:
				max_allowed = h
		if max_allowed > 0:
			for r in range(max_allowed):
				var row_y := base_row - vertical_row_spacing * (r + 1)
				var px := 0
				while px < cells_wide:
					# Only consider spawning if this column allows this row
					if allowed_heights[px] > r and rng.randi_range(0, platform_spacing) == 0:
						var length := rng.randi_range(platform_min_length, platform_max_length)
						for lx in range(length):
							var cx := px + lx
							if cx >= cells_wide:
								break
							
							# grass
							if length >= 2:
								if lx == 0:
									tile.set_cell(Vector2i(cx, row_y), 0, tiles["grass"][1001])
								elif lx == length - 1:
									tile.set_cell(Vector2i(cx, row_y), 0, tiles["grass"][1002])
								else:
									tile.set_cell(Vector2i(cx, row_y), 0, tiles["grass"][0])
							
							# dirt under platform
							if length >= 2:
								if lx == 0:
									tile.set_cell(Vector2i(cx, row_y+1), 0, tiles["b_dirt"][1001])
								elif lx == length - 1:
									tile.set_cell(Vector2i(cx, row_y+1), 0, tiles["b_dirt"][1002])
								else:
									tile.set_cell(Vector2i(cx, row_y+1), 0, tiles["b_dirt"][rng.randi_range(0,1)])
							
						# advance x by platform length plus configured spacing to ensure gaps
						px += max(1, length) + platform_spacing
					else:
						px += 1
		
	elif loc == 1:
		# Number of horizontal cells to fill (cover visible + a bit of buffer)
		@warning_ignore("integer_division")
		var cells_wide := int(ceil(M.screen.x / tile_size)) + 8

		# Generate base ground row and record how many extra rows allowed per column
		var allowed_heights := []
		for x in range(cells_wide):
			var gx := x + loc * cells_wide
			# smooth height from noise
			var n = noise.get_noise_1d(float(gx))
			# map noise [-1,1] to additional rows count
			var additional_rows := int(round(((n + 1.0) / 2.0) * max_additional_rows))
			allowed_heights.append(additional_rows)

			var ground_y := base_row
			# Place main base tile (dirt)
			# Use dirt tile id 0 from tiles mapping
			for i in range(5):
				tile.set_cell(Vector2i(x, ground_y + i), 0, tiles["dirt_desert"][rng.randi_range(0,1)])


func _physics_process(_delta: float) -> void:
	if !M.game: return
	if M.home: return
	
	move_tile(tile_0)
	move_tile(tile_1)
	
	M.C.way_bar.pvalue += speed * Engine.time_scale


func _on_item_spawn_cd_timeout() -> void:
	if !M.game: return
	var rng := RandomNumberGenerator.new()
	rng.seed = location + distance + world_seed
	$ItemSpawner/ItemSpawnCD.wait_time = randf_range(0.5, 5.0)
	for i in range(floor(float(distance) / 10) + 1):
		item_spawner.spawn(world_seed + i, M.screen.x, location, distance)
	$ItemSpawner/ItemSpawnCD.start()
