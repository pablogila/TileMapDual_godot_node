@tool
class_name TileMapDual
extends TileMapLayer

## World TileMapLayer.
## An offset of (-0.5,-0.5) tiles will be applied
## with respect to the World grid.
@export var world_tilemap: TileMapLayer
## Coordinates for the tile in the Atlas
## that will be used to sketch in-editor in the World TileMapLayer.
## Defaults to the one in the official Godot template.
@export var sketch_atlas_coord: Vector2i = Vector2i(2,1)

## Bit-wise logic: summing over all neighbours
## provides the proper tile from the Atlas.
enum direction {
	TOP_LEFT  = 1,
	LOW_LEFT  = 2,
	TOP_RIGHT = 4,
	LOW_RIGHT = 8
	}

## Overlapping tiles from the World grid
## that a tile from TileMapDual has.
const NEIGHBOURS := {
	direction.TOP_LEFT  : Vector2(0,0),
	direction.LOW_LEFT  : Vector2(0,1),
	direction.TOP_RIGHT : Vector2(1,0),
	direction.LOW_RIGHT : Vector2(1,1)
	}

## Sum the NEIGHBOURS, and assign the coordinates to the Atlas.
## Folloes the official 2x2 template.
const NEIGHBOURS_TO_ATLAS: Dictionary = {
	 0: Vector2(3,0),
	 1: Vector2(3,3),
	 2: Vector2(0,0),
	 3: Vector2(3,2),
	 4: Vector2(0,1),
	 5: Vector2(1,2),
	 6: Vector2(2,3),
	 7: Vector2(3,1),
	 8: Vector2(1,3),
	 9: Vector2(0,1),
	10: Vector2(0,3),
	11: Vector2(0,2),
	12: Vector2(0,1),
	13: Vector2(2,2),
	14: Vector2(1,1),
	15: Vector2(2,1)
	}


func _ready() -> void:
	world_tilemap.changed.connect(_update_tilemap)
	_update_tiles()


func _update_tilemap() -> void:
	self.tile_set = world_tilemap.tile_set
	self.position.x = - self.tile_set.tile_size.x * 0.5
	self.position.y = - self.tile_set.tile_size.y * 0.5
	_update_tiles()
	print('TileMap updated')


func _update_tiles() -> void:
	for _world_cell in world_tilemap.get_used_cells():
		if _is_world_tile_sketched(_world_cell):
			print(_world_cell)
			_update_tiles_around_world_tile(_world_cell)


func _is_world_tile_sketched(coords: Vector2i) -> bool:
	var atlas_coord = get_cell_atlas_coords(coords)
	if atlas_coord == sketch_atlas_coord:
		return true
	else:
		return false


func _update_tiles_around_world_tile(_coords: Vector2i) -> void:
	for _key in NEIGHBOURS:
		var _displaced_tile = _coords + NEIGHBOURS[_key]
		_update_tile_at_coord(_displaced_tile)
	
	#var top_left = _coords + NEIGHBOURS.direction.TOP_LEFT
	#var low_left = _coords + NEIGHBOURS.direction.LOW_LEFT
	#var top_right = _coords + NEIGHBOURS.direction.TOP_RIGHT
	#var low_right = _coords + NEIGHBOURS.direction.LOW_RIGHT
	#_update_tile_at_coord(top_left)
	#_update_tile_at_coord(low_left)
	#_update_tile_at_coord(top_right)
	#_update_tile_at_coord(low_right)


func _update_tile_at_coord(_coords: Vector2i) -> void:
	var _world_top_left: Vector2i = _coords + NEIGHBOURS.direction.TOP_LEFT
	var _world_low_left: Vector2i = _coords + NEIGHBOURS.direction.LOW_LEFT
	var _world_top_right: Vector2i = _coords + NEIGHBOURS.direction.TOP_RIGHT
	var _world_low_right: Vector2i = _coords + NEIGHBOURS.direction.LOW_RIGHT
	
	var _coords_atlas: Vector2i
	var _tile_key: int = 0
	if _is_world_tile_sketched(_world_top_left):
		_tile_key += direction.TOP_LEFT
	if _is_world_tile_sketched(_world_low_left):
		_tile_key += direction.LOW_LEFT
	if _is_world_tile_sketched(_world_top_right):
		_tile_key += direction.TOP_RIGHT
	if _is_world_tile_sketched(_world_low_right):
		_tile_key += direction.LOW_RIGHT
	
	_coords_atlas = NEIGHBOURS_TO_ATLAS[_tile_key]
	self.set_cell(_coords, 0, _coords_atlas)
	
