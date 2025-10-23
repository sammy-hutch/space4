extends CharacterBody2D

var active: bool = false
var available: bool = false
var map_data: TileMapLayer
var nav_area: Dictionary
var playable: bool = false
var speed: int = 5
var soldiers_data: Dictionary
var target_tile: Vector2
var team: String = "none"
var tile_pos: Vector2

@onready var tile_map_layer: TileMapLayer = $TileMapLayer
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var clickbox: Area2D = $Sprite2D/ClickBox

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
	tile_map_layer.visible = false
	
	if clickbox:
		clickbox.input_event.connect(_on_area_2d_input_event)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	# try to move to mouse clicks
	if active and target_tile:
		tile_pos += target_tile
		
		# for now just teleport to position and deactivate
		position = tile_pos * map_data.TILE_SIZE
		deactivate()
		
		

func _input(event: InputEvent):
	# check for mouse clicks in navigable area
	if active:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			var event_position = get_local_mouse_position()
			var event_tile = tile_map_layer.local_to_map(event_position)
			var coords = str(event_tile.y) + "_" + str(event_tile.x)
			if nav_area.has(coords):
				target_tile = event_tile
			else: 
				deactivate()
			

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
			tile_pos = Vector2(x, y)
			position.x = x * map_data.TILE_SIZE
			position.y = y * map_data.TILE_SIZE
			located = true


func deactivate():
	active = false
	target_tile = Vector2(0,0)
	tile_map_layer.visible = false
	nav_area.clear()
	tile_map_layer.clear()


func generate_nav_map():
	nav_area = { "0_0": { "dist": 0, "y": 0, "x": 0 } }
	var map: Array[Array] = map_data.map
	var counter = 1
	while counter <= speed:
		# iterate over dict to scan for available areas and add to dict
		for tile in nav_area.values():
			# only check latest tiles
			if tile["dist"] == counter-1:
				# set vars
				var dist = counter
				var x = tile["x"]
				var y = tile["y"]
				
				#create adjacents
				var adjacents = {
					"n": { "dist": dist, "x": x, "y": y-1 },
					"e": { "dist": dist, "x": x+1, "y": y },
					"s": { "dist": dist, "x": x, "y": y+1 },
					"w": { "dist": dist, "x": x-1, "y": y }
				}
				
				# check if space is navigable, and if so assign to dict
				for a in adjacents.values():
					var a_x = a["x"]
					var a_y = a["y"]
					var coords = str(a_y) + "_" + str(a_x)
					if not nav_area.has(coords) \
					and map[(a_y + tile_pos.y)][(a_x + tile_pos.x)] != 1:
						nav_area[coords] = { "dist": dist, "y": a_y, "x": a_x }
						tile_map_layer.set_cell(Vector2i(a_x,a_y), 0, Vector2i(0,0))
		
		# increment counter after checking all tiles
		counter += 1


# scans map for valid targets and returns them as a list of coords
func scan_for_targets():
	pass


# provided with a target, find_path() calculates shortest route to that target
# and returns series of tiles as a "path"
func find_path(target: Vector2):
	pass


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		active = !active
		if active:
			tile_map_layer.visible = true
			generate_nav_map()
		if !active:
			deactivate()
