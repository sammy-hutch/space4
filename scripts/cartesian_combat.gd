extends Node2D

const max_zoom = Vector2(100, 100)
const min_zoom = Vector2(0.1, 0.1)
const soldier_count: int = 1


var soldiers_data: Dictionary = {}
var SoldierScene: PackedScene = preload("res://scenes/cartesian_soldier.tscn")

@onready var map_node: Node2D
@onready var camera_2d: Camera2D = $Camera2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	generate_new_map()
	spawn_soldiers("blue", 5)
	spawn_soldiers("red", 5)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var zoom_axis := Input.get_axis("zoom out", "zoom in")
	var zoom := Vector2(zoom_axis, zoom_axis)*0.2
	if zoom:
		print("zoom_axis:")
		print(zoom)
		var new_zoom = camera_2d.zoom + zoom
		if new_zoom < max_zoom and new_zoom > min_zoom:
			camera_2d.zoom = new_zoom
		print("new zoom")
		print(camera_2d.zoom)
	
	#if Input.is_action_just_pressed("load new map"):
		#generate_new_map()

func generate_new_map():
	#print("generating new map")
	var new_map = preload("res://scenes/map.tscn")
	if new_map:
		var current_new_map = new_map.instantiate()
		if map_node and map_node.get_parent():
			map_node.queue_free()
		add_child(current_new_map)
		map_node = current_new_map
		#print("new map loaded")
	#else:
		#print("failed to load next map scene")

func spawn_soldiers(team, count):
	var max_count = count
	while count > 0:
		# create new soldier child scene
		var new_soldier = SoldierScene.instantiate()
		var number = (max_count - (count - 1))
		new_soldier.name = team + "_%d" % number
		new_soldier.team = team
		add_child(new_soldier)
		
		# add new soldier's data to global tracker
		var soldier_data = {
			"team": team,
			"number": number,
			"x_pos": new_soldier.tile_x,
			"y_pos": new_soldier.tile_y
		}
		soldiers_data[new_soldier.name] = soldier_data
		
		count -= 1
	
func get_map_data():
	return map_node.get_node("TileMapLayer")

func get_soldiers_data():
	return soldiers_data
