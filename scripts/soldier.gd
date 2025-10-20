extends Node2D

var speed: int = 5
var playable: bool = false
var active: bool = false
var available: bool = false
var tile_x: int = 0
var tile_y: int = 0
var team: String = "none"
var map_data: TileMapLayer
var soldiers_data: Dictionary

@onready var tile_map_layer: TileMapLayer = $TileMapLayer
@onready var sprite_2d: Sprite2D = $Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# get relevant vars from parent
	if get_parent():
		if get_parent().has_method("get_map_data"):
			map_data = get_parent().get_map_data()
		else:
			printerr("soldier.gd: Parent does not have 'get_map_data' method")
		if get_parent().has_method("get_soldiers_data"):
			soldiers_data = get_parent().get_soldiers_data()
		else:
			printerr("soldier.gd: Parent does not have 'get_soldiers_data' method")
	else:
		printerr("soldier.gd: Parent not found")
	
	# spawn soldier
	spawn()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func spawn():
	# set existing soldier positions array
	var soldiers_pos = []
	for soldier in soldiers_data.values():
		soldiers_pos.append(str(soldier["x_pos"]) + "_" + str(soldier["y_pos"]))
	
	# set colour of soldier
	if team == "blue":
		sprite_2d.modulate = Color(0.5, 0.5, 1, 1)
		sprite_2d.rotation = 0.5*PI
		playable = true
	elif team == "red":
		sprite_2d.modulate = Color(1, 0.5, 0.5, 1)
		sprite_2d.rotation = -0.5*PI
	
	# set position of soldier
	var map: Array[Array] = map_data.map
	var map_height = map.size()
	var map_width = map[0].size()
	var located = false
	while located == false:
		var y = randi_range(0, map_height-1)
		var x = 0
		# spawn blue on left..
		if team == "blue":
			x = randi_range(0, round((map_width-1) * 0.25))
		# .. and red on right
		elif team == "red":
			x = randi_range(round(0.75 * (map_width-1)), map_width-1)
		# check if tile is open, non-occupied space
		if map[y][x] == 0 and soldiers_pos.has(str(x) + "_" + str(y)) == false:
			tile_x = x
			tile_y = y
			position.x = x * map_data.TILE_SIZE
			position.y = y * map_data.TILE_SIZE
			located = true

func pathfinding():
	# create start of navigable area dict
	var navigable_area = {
		"0_0": { "dist": 0, "x": 0, "y": 0 }
	}
	
	# iterate over dict to scan for available areas and add to dict
	for tile in navigable_area:
		# set vars
		var data = navigable_area[tile]
		var dist = data["dist"] + 1
		var x = data["x"]
		var y = data["y"]
		
		#create adjacents
		var adjacents = {
			"n": { "dist": dist, "x": x, "y": y-1 },
			"e": { "dist": dist, "x": x+1, "y": y },
			"s": { "dist": dist, "x": x, "y": y+1 },
			"w": { "dist": dist, "x": x-1, "y": y }
		}
		
		#for a in adjacents.values():
