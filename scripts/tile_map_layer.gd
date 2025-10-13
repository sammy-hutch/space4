extends TileMapLayer

var MAP_TILE_WIDTH = 50
var MAP_TILE_HEIGHT = 25
var TILE_SIZE = 16


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var schema = generate_empty_schema()
	var basic_map = generate_basic_map(schema)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func generate_empty_schema():
	# create empty schema
	print("creating schema")
	var schema = []
	for r in range (MAP_TILE_HEIGHT):
		var row = []
		for tile in range(MAP_TILE_WIDTH):
			row.append(-1)
		schema.append(row)
	print("schema created")
	print(schema)
	return schema

func generate_basic_map(schema):
	print("generating map")
	var map = schema
	
	# add borders by default
	for y in range(MAP_TILE_HEIGHT):
		for x in range(MAP_TILE_WIDTH):
			if x == 0 \
			or x == MAP_TILE_WIDTH-1 \
			or y == 0 \
			or y == MAP_TILE_HEIGHT-1:
				map[y][x] = 1
				set_cell(Vector2i(x,y), 0, Vector2i(0,1))
	
	# add inner tiles
	var tiles_to_fill = (MAP_TILE_HEIGHT-2) * (MAP_TILE_WIDTH-2)
	while tiles_to_fill > 0:
		var x = randi_range(1, MAP_TILE_WIDTH-2)
		var y = randi_range(1, MAP_TILE_HEIGHT-2)
		if map[y][x] == -1:
			var barrier_heat = calculate_barrier_chance(x, y, map)
			if barrier_heat > randf():
				map[y][x] = 1
				set_cell(Vector2i(x,y), 0, Vector2i(0,1))
			else:
				map[y][x] = 0
				set_cell(Vector2i(x,y), 0, Vector2i(0,0))
			tiles_to_fill -= 1
	print("map generated")
	print(map)
	return map

func calculate_barrier_chance(x, y, map):
	# set initial probability for barrier to spawn
	var p = 0.4
	# set clustering strength
	var c = 0.05
	
	#cluster barriers by making them more likely near other barriers
	var adjacent_tile_array = [
		map[y-1][x-1],
		map[y-1][x],
		map[y-1][x+1],
		map[y][x-1],
		map[y][x+1],
		map[y+1][x-1],
		map[y+1][x],
		map[y+1][x+1],
	]
	for tile in adjacent_tile_array:
		if tile == 1: p += c
		if tile == 0: p -= c
	
	return p
	
	
