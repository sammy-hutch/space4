extends Node2D

@export var players: Array = ["player1"]

const max_zoom = Vector2(100, 100)
const min_zoom = Vector2(0.1, 0.1)
const soldier_count: int = 1


var soldiers: Dictionary = {}
var SoldierScene: PackedScene = preload("res://scenes/cartesian_soldier.tscn")
var teams: Dictionary = {
	"blue": {
		"team_name": null,
		"type": null,
		"turn": 0,
		"soldiers": {}
	},
	"red": {
		"team_name": null,
		"type": null,
		"turn": 0,
		"soldiers": {}
	}
}
var active_team: String

@onready var map_node: Node2D
@onready var camera_2d: Camera2D = $Camera2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	generate_new_map()
	# assign team data
	teams["blue"]["team_name"] = players[0] if players.size() >= 1 else "computer"
	teams["blue"]["type"] = "human" if players.size() >= 1 else "computer"
	teams["red"]["team_name"] = players[1] if players.size() >= 2 else "computer"
	teams["red"]["type"] = "human" if players.size() >= 2 else "computer"
	# spawn soldiers
	spawn_soldiers("blue", 5)
	spawn_soldiers("red", 5)
	
	# set first turn to blue player
	active_team = "blue"
	start_turn(active_team)


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

func generate_new_map():
	var new_map = preload("res://scenes/map.tscn")
	if new_map:
		var current_new_map = new_map.instantiate()
		if map_node and map_node.get_parent():
			map_node.queue_free()
		add_child(current_new_map)
		map_node = current_new_map
	else:
		print("failed to load next map scene")


###### TURN MGMT FUNCTIONS ######
func start_turn(team: String):
	teams[team]["turn"] += 1
	for soldier in teams[team]["soldiers"].values():
		soldier.ready_soldier()
	if teams[team]["type"] == "computer":
		ai_turn()

func check_turn_end():
	var all_moved = true
	for soldier in teams[active_team]["soldiers"].values():
		if soldier.available:
			all_moved = false
			break
	if all_moved:
		end_turn()

func end_turn():
	for soldier in teams[active_team]["soldiers"].values():
		soldier.unready_soldier()
	var new_team = ""
	if active_team == "blue":
		new_team = "red"
	elif active_team == "red":
		new_team = "blue"
	else:
		printerr("invalid value assigned to whos_turn var: %s" % active_team)
	active_team = new_team
	start_turn(active_team)

###### SOLDIER MGMT FUNCTIONS ######
func spawn_soldiers(team, count):
	var max_count = count
	while count > 0:
		# create new soldier child scene
		var new_soldier = SoldierScene.instantiate()
		var number = (max_count - (count - 1))
		new_soldier.name = team + "_%d" % number
		new_soldier.team = team
		add_child(new_soldier)
		new_soldier.finished_move.connect(_on_soldier_finished)
		count -= 1

func register_soldier(soldier_node: Node):
	var soldier_id = soldier_node.name
	if soldier_id in soldiers:
		push_warning("Soldier with ID '%s' already registered!" % soldier_id)
		return
	soldiers[soldier_id] = soldier_node
	teams[soldier_node.team]["soldiers"][soldier_id] = soldier_node

func unregister_soldier(soldier_node: Node):
	var soldier_id = soldier_node.name
	if soldier_id in soldiers:
		soldiers.erase(soldier_id)
		teams[soldier_node.team]["soldiers"].erase(soldier_id)


###### DATA QUERY FUNCTIONS ######
func get_soldier_position(soldier_id: String) -> Vector2:
	if soldiers.has(soldier_id):
		return soldiers[soldier_id].tile_pos
	push_warning("Soldier '%s' not found!" % soldier_id)
	return Vector2.ZERO

func get_team_positions(teams: Array) -> Dictionary:
	var all_positions: Dictionary = {}
	for soldier in soldiers:
		for team in teams:
			if soldiers[soldier].team == team:
				all_positions[soldier] = soldiers[soldier].tile_pos
	return all_positions
	
func get_map_data():
	return map_node.get_node("TileMapLayer")

func get_soldiers_data():
	return soldiers

func get_teams_data():
	return teams


###### AI FUNCTIONS ######
func ai_turn():
	end_turn()


###### SIGNAL FUNCTIONS ######
func _on_soldier_finished(soldier_node):
	check_turn_end()
