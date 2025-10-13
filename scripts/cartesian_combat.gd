extends Node2D

const max_zoom = Vector2(100, 100)
const min_zoom = Vector2(0.1, 0.1)



#@onready var map_node: Node2D = $Map
@onready var camera_2d: Camera2D = $Camera2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


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

#func generate_new_map():
	#print("generating new map")
	#var new_map = preload("res://scenes/map.tscn")
	#if new_map:
		#var current_new_map = new_map.instantiate()
		#if map_node and map_node.get_parent():
			#map_node.queue_free()
		#add_child(current_new_map)
		#map_node = current_new_map
		#print("new map loaded")
	#else:
		#print("failed to load next map scene")
