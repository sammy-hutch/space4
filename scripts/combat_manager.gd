extends Node2D

var SoldierScene: PackedScene = preload("res://Scenes/soldier.tscn")
@onready var tile_map_layer: TileMapLayer = $TileMapLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var soldier_count = 1
	var enemy_count = 4
	for soldier in range(soldier_count):
		var soldier_instance = SoldierScene.instantiate()
		soldier_instance.position = spawn_soldier()
		add_child(soldier_instance)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func spawn_soldier():
	var x = randi_range(-125, 0)
	var y = randi_range(-125, 125)
	var general_position = Vector2(x,y)
	var map_position = tile_map_layer.to_local(general_position)
	position = tile_map_layer.to_global(map_position)
	print(general_position)
	print(map_position)
	print(position)
	return position
