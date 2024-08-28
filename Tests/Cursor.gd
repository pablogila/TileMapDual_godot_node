extends Node2D

@export var world_tilemap: TileMapLayer
@export var dual_tilemap: TileMapDual

@onready var coords: Vector2i


func _ready() -> void:
	await owner.ready
	if dual_tilemap != null and world_tilemap == null:
		world_tilemap = dual_tilemap.sketch_tilemap


func _process(_delta: float) -> void:
	coords = world_tilemap.local_to_map(position)
	
	if Input.is_action_pressed("left_click"):
		world_tilemap.set_cell(coords, 0, dual_tilemap.sketch_atlas_coords)
		if dual_tilemap.update_in_game:
			dual_tilemap.update_tilemap()
	elif Input.is_action_pressed("right_click"):
		world_tilemap.set_cell(coords, 0, dual_tilemap.empty_atlas_coords)
		if dual_tilemap.update_in_game:
			dual_tilemap.update_tilemap()


func _physics_process(_delta: float) -> void:
	var world_pos = get_world_pos_tile(get_global_mouse_position())
	global_position = world_pos + Vector2i(8, 8)


func get_world_pos_tile(world_pos: Vector2) -> Vector2i:
	var x_int: int = int(floor(world_pos.x / 16) * 16)
	var y_int: int = int(floor(world_pos.y / 16) * 16)
	return Vector2i(x_int, y_int)
