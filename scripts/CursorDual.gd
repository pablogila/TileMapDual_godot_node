class_name CursorDual
extends Sprite2D

@export var world_tilemap: TileMapLayer = null
@export var dual_tilemap: TileMapDual = null

var cell: Vector2i
var tile_size: Vector2
var sprite_size: Vector2


func _ready() -> void:
	if world_tilemap != null:
		tile_size = world_tilemap.tile_set.tile_size
		sprite_size = self.texture.get_size()
		scale = tile_size / sprite_size
		self.set_scale(scale)


func _process(_delta: float) -> void:
	if world_tilemap == null:
		return
	global_position = world_tilemap.map_to_local(world_tilemap.local_to_map(get_global_mouse_position()))
	if dual_tilemap == null:
		return
	cell = world_tilemap.local_to_map(global_position)
	if Input.is_action_pressed("left_click"):
		dual_tilemap.fill_tile(cell)
	elif Input.is_action_pressed("right_click"):
		dual_tilemap.erase_tile(cell)
