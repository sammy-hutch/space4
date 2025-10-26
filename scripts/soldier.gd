extends CharacterBody2D


###### INIT VARS ######
var team: String = "none"
###### STATE VARS ######
var active: bool = false
var available: bool = false
var is_moving: bool = false
var playable: bool = false
###### REFERENCE VARS ######
var map_data: TileMapLayer
var soldiers_data: Dictionary
###### NAV VARS ######
var nav_area: Dictionary
var target_tile: Vector2i
var tile_pos: Vector2i
var walk_range: int = 5
###### MOVEMENT VARS ######
var movement_tween: Tween = null
var path: Array = []
var path_index: int = 0
var speed = 100

@onready var tile_map_layer: TileMapLayer = $TileMapLayer
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var clickbox: Area2D = $Sprite2D/ClickBox


###### INIT FUNCTIONS ######
func _ready() -> void:
	# get relevant vars from parent
	var combat_manager = get_parent()
	if not combat_manager:
		printerr("soldier.gd: Parent not found")
	
	if combat_manager.has_method("get_map_data"):
		map_data = combat_manager.get_map_data()
	else:
		printerr("soldier.gd: Parent does not have 'get_map_data' method")
	
	if combat_manager.has_method("get_soldiers_data"):
		soldiers_data = combat_manager.get_soldiers_data()
	else:
		printerr("soldier.gd: Parent does not have 'get_soldiers_data' method")
	
	# spawn soldier
	spawn()
	
	# register soldier to combat manager global tracker
	if combat_manager.has_method("register_soldier"):
		combat_manager.register_soldier(self)
	else:
		printerr("soldier.gd: Parent does not have 'get_soldiers_data' method")
	
	tile_map_layer.visible = false
	
	if clickbox:
		clickbox.input_event.connect(_on_area_2d_input_event)

func spawn():
	# collect latest soldier positions
	var soldiers_pos = get_parent().get_team_positions(["blue", "red"])
	var teams = get_parent().get_teams_data()
	
	# set rotation of soldier
	if team == "blue":
		sprite_2d.rotation = 0.5*PI
	elif team == "red":
		sprite_2d.rotation = -0.5*PI
	
	# make soldier playable if on human-controlled team
	if teams[team]["type"] == "human":
		playable = true
	
	# unready soldier
	unready_soldier()
	
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
		if map[y][x] == 0 and soldiers_pos.values().has(Vector2i(x,y)) == false:
			tile_pos = Vector2i(x, y)
			position.x = x * map_data.TILE_SIZE
			position.y = y * map_data.TILE_SIZE
			located = true


###### STATE MGMT FUNCTIONS ######
func deactivate():
	active = false
	target_tile = Vector2i(0,0)
	tile_map_layer.visible = false
	nav_area.clear()
	tile_map_layer.clear()
	path.clear()
	tile_pos = map_data.local_to_map(position)

func ready_soldier():
	available = true
	if team == "blue":
		sprite_2d.modulate = Color(0.5, 0.5, 1, 1)
	elif team == "red":
		sprite_2d.modulate = Color(1, 0.5, 0.5, 1)

func unready_soldier():
	available = false
	if team == "blue":
		sprite_2d.modulate = Color(0.25, 0.25, 0.5, 1)
	elif team == "red":
		sprite_2d.modulate = Color(0.5, 0.25, 0.25, 1)
	

###### INPUT FUNCTIONS ######
func _input(event: InputEvent):
	# check for mouse clicks in navigable area
	if active and playable:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			var event_position = get_local_mouse_position()
			var event_tile = map_data.local_to_map(event_position)
			var coords = str(int(event_tile.x)) + "_" + str(int(event_tile.y))
			if nav_area.has(coords):
				target_tile = event_tile
				nav_area.clear()
				tile_map_layer.clear()
				path = find_path(target_tile)
				start_movement(path)
			else: 
				deactivate()


###### MOVEMENT FUNCTIONS ######
func start_movement(path: Array):
	if path.is_empty():
		return
	
	stop_movement()
	
	path_index = 0
	is_moving = true
	_move_to_next_tile()

func stop_movement():
	if movement_tween and movement_tween.is_running():
		movement_tween.kill()
		is_moving = false
		path = []
		path_index = 0

func _move_to_next_tile():
	if not is_moving:
		return
	
	# end if at end of path
	if path_index >= path.size():
		is_moving = false
		path = []
		path_index = 0
		deactivate()
		unready_soldier() # for now, unready after move
		return
	
	var next_tile_coords: Vector2i = path[path_index]
	var target_pos: Vector2 = get_world_position_of_tile_centre(next_tile_coords)
	var distance = position.distance_to(target_pos)
	var duration = distance / speed
	
	# create new tween for this segment of path
	movement_tween = create_tween()
	movement_tween.set_ease(Tween.EASE_IN_OUT)
	movement_tween.set_trans(Tween.TRANS_LINEAR)
	
	#tween character's position to target position
	movement_tween.tween_property(self, "position", target_pos, duration)
	
	# when tween finishes, trigger movement to next tile
	movement_tween.tween_callback(func():
		tile_pos = map_data.local_to_map(position)
		path_index += 1
		_move_to_next_tile()
	)


###### NAV FUNCTIONS ######
func generate_nav_map():
	nav_area = { "0_0": { "dist": 0, "y": 0, "x": 0 } }
	var map: Array[Array] = map_data.map
	var soldiers_pos = get_parent().get_team_positions(["blue", "red"])
	var counter = 1
	while counter <= walk_range:
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
					var a_pos = Vector2i(a_x, a_y)
					var coords = str(a_x) + "_" + str(a_y)
					if not nav_area.has(coords) \
					and map[(a_y + tile_pos.y)][(a_x + tile_pos.x)] != 1 \
					and soldiers_pos.values().has(Vector2i((a_x + tile_pos.x) , (a_y + tile_pos.y))) == false:
						nav_area[coords] = { "dist": dist, "y": a_y, "x": a_x }
						tile_map_layer.set_cell(a_pos, 0, Vector2i(0,0))
		
		# increment counter after checking all tiles
		counter += 1


# provided with a target, find_path() calculates shortest route to that target
# and returns series of tiles as a "path"
func find_path(target: Vector2i) -> Array:
	# setup vars
	nav_area = { 
		"0_0": { 
			"dist": 0, 
			"y": 0, 
			"x": 0,
			"prev_tile": null
			} 
		}
	var map: Array[Array] = map_data.map
	var soldiers_pos = get_parent().get_team_positions(["blue", "red"])
	var counter = 0
	var found = false
	var accessible = true
	
	# iterate over adjacent tiles until found target, or determined that target is inaccessible
	while found == false and accessible == true:
		counter += 1
		var new_tiles_found = false
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
					var a_pos = Vector2i(a_x, a_y)
					var coords = str(a_x) + "_" + str(a_y)
					if a_pos == target:
						nav_area[coords] = { "dist": dist, "y": a_y, "x": a_x, "prev_tile": Vector2i(x,y) }
						found = true
						new_tiles_found = true
					if not nav_area.has(coords) \
					and map[(a_y + tile_pos.y)][(a_x + tile_pos.x)] != 1 \
					and soldiers_pos.values().has(Vector2i((a_x + tile_pos.x) , (a_y + tile_pos.y))) == false:
						nav_area[coords] = { "dist": dist, "y": a_y, "x": a_x, "prev_tile": Vector2i(x,y) }
						new_tiles_found = true
		if new_tiles_found == false:
			accessible = false
	
	# iterate over nav area to build path to target
	if found == true:
		var next_step = target
		# builds path, starting furthest away and iterating closer
		while next_step != tile_pos and counter > 0:
			path.append(next_step + tile_pos)
			counter -= 1
			var coords = str(int(next_step.x)) + "_" + str(int(next_step.y))
			next_step = nav_area[coords]["prev_tile"]
		# reverse array so is ordered nearest-furthest
		path.reverse()
	
	return path


###### HELPER FUNCTIONS ######

func get_world_position_of_tile_centre(tile_coords: Vector2i) -> Vector2:
	var tile_size = map_data.tile_set.tile_size
	var nw_corner = map_data.map_to_local(tile_coords)
	var centre = Vector2(tile_size.x / 2.0, tile_size.y / 2.0)
	return  nw_corner - centre 


###### SIGNAL FUNCTIONS ######

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and event.is_pressed() \
	and playable and available:
		active = !active
		if active:
			tile_map_layer.visible = true
			generate_nav_map()
		if !active:
			deactivate()
