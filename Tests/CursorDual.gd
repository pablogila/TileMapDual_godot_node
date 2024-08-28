class_name CursorDual
extends Node2D

# TO-DO: generalize the grid size

@export var world_tilemap: TileMapLayer
@export var dual_tilemap: TileMapDual

@onready var coords: Vector2i


func _process(_delta: float) -> void:
	coords = world_tilemap.local_to_map(position)
	
	if Input.is_action_pressed("left_click"):
		dual_tilemap.fill_tile(coords)
	elif Input.is_action_pressed("right_click"):
		dual_tilemap.erase_tile(coords)


func _physics_process(_delta: float) -> void:
	var world_pos = get_world_pos_tile(get_global_mouse_position())
	global_position = world_pos + Vector2i(8, 8)


func get_world_pos_tile(world_pos: Vector2) -> Vector2i:
	var x_int: int = int(floor(world_pos.x / 16) * 16)
	var y_int: int = int(floor(world_pos.y / 16) * 16)
	return Vector2i(x_int, y_int)
