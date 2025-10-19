extends Node2D

var speed: int = 5
var playable: bool = false
var active: bool = false
var available: bool = false
var tile_x: int = 0
var tile_y: int = 0

@onready var tile_map_layer: TileMapLayer = $TileMapLayer
@onready var sprite_2d: Sprite2D = $Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func spawn(team, tileMapLayer, soldiers_data: Dictionary):
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
	var map: Array[Array] = tileMapLayer.map
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
			position.x = (x + 0.5) * tileMapLayer.TILE_SIZE # + 0.5 of tile size to position in centre of tile
			position.y = (y + 0.5) * tileMapLayer.TILE_SIZE
			located = true
