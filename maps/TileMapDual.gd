@tool
class_name TileMapDual
extends TileMapLayer

@export var debug: bool = false
## World TileMapLayer, where the tiles are sketched.
## An offset of (-0.5,-0.5) tiles will be applied
## with respect to the World grid.
@export var world_tilemap: TileMapLayer
## coordinates for the tile in the Atlas
## that will be used to sketch in-editor in the World TileMapLayer.
## Defaults to the one in the official Godot template.
@export var sketch_atlas_coords: Vector2i = Vector2i(2,1)

## Bit-wise logic: summing over all neighbours
## provides the proper tile from the Atlas.
enum location {
	TOP_LEFT  = 1,
	LOW_LEFT  = 2,
	TOP_RIGHT = 4,
	LOW_RIGHT = 8
	}

## Overlapping tiles from the World grid
## that a tile from TileMapDual has.
const NEIGHBOURS := {
	location.TOP_LEFT  : Vector2i(0,0),
	location.LOW_LEFT  : Vector2i(0,1),
	location.TOP_RIGHT : Vector2i(1,0),
	location.LOW_RIGHT : Vector2i(1,1)
	}

## Dict to assign the Atlas coordinates from the
## summation over all sketched NEIGHBOURS.
## Follows the official 2x2 template.
const NEIGHBOURS_TO_ATLAS: Dictionary = {
	 0: Vector2i(3,0),
	 1: Vector2i(3,3),
	 2: Vector2i(0,0),
	 3: Vector2i(3,2),
	 4: Vector2i(0,1),
	 5: Vector2i(1,2),
	 6: Vector2i(2,3),
	 7: Vector2i(3,1),
	 8: Vector2i(1,3),
	 9: Vector2i(0,1),
	10: Vector2i(0,3),
	11: Vector2i(0,2),
	12: Vector2i(0,1),
	13: Vector2i(2,2),
	14: Vector2i(1,1),
	15: Vector2i(2,1)
	}


func _ready() -> void:
	world_tilemap.changed.connect(_update_tilemap)


func _update_tilemap() -> void:
	self.tile_set = world_tilemap.tile_set
	self.position.x = - self.tile_set.tile_size.x * 0.5
	self.position.y = - self.tile_set.tile_size.y * 0.5
	_update_tiles()


func _update_tiles() -> void:
	if debug:
		print('Updating tiles....................')
	for _world_cell in world_tilemap.get_used_cells():
		_update_tiles_around_world_cell(_world_cell)


func _update_tiles_around_world_cell(_world_cell: Vector2i) -> void:
	if debug:
		print('  Updating displayed cells around world cell ' + str(_world_cell) + '...')
	var _top_left = _world_cell + NEIGHBOURS[location.TOP_LEFT]
	var _low_left = _world_cell + NEIGHBOURS[location.LOW_LEFT]
	var _top_right = _world_cell + NEIGHBOURS[location.TOP_RIGHT]
	var _low_right = _world_cell + NEIGHBOURS[location.LOW_RIGHT]
	_update_tile_at_coords(_top_left)
	_update_tile_at_coords(_low_left)
	_update_tile_at_coords(_top_right)
	_update_tile_at_coords(_low_right)


func _update_tile_at_coords(_coords: Vector2i) -> void:
	
	if debug:
		print('    Checking display tile ' + str(_coords) + '...')
	
	var _coords_atlas: Vector2i
	var _tile_key: int = 0
	
	var _top_left = _coords - NEIGHBOURS[location.LOW_RIGHT]
	var _low_left = _coords - NEIGHBOURS[location.TOP_RIGHT]
	var _top_right = _coords - NEIGHBOURS[location.LOW_LEFT]
	var _low_right = _coords - NEIGHBOURS[location.TOP_LEFT]
	
	if _is_world_tile_sketched(_top_left):
		_tile_key += location.TOP_LEFT
	if _is_world_tile_sketched(_low_left):
		_tile_key += location.LOW_LEFT
	if _is_world_tile_sketched(_top_right):
		_tile_key += location.TOP_RIGHT
	if _is_world_tile_sketched(_low_right):
		_tile_key += location.LOW_RIGHT
	
	#for _key in NEIGHBOURS:
	#	var _world_cell = _coords + NEIGHBOURS[_key]
	#	if _is_world_tile_sketched(_world_cell):
	#		_tile_key += _key
	
	_coords_atlas = NEIGHBOURS_TO_ATLAS[_tile_key]
	self.set_cell(_coords, 0, _coords_atlas)
	if debug:
		print('    Display tile ' + str(_coords) + ' updated with key ' + str(_tile_key))


func _is_world_tile_sketched(_coords: Vector2i) -> bool:
	var _atlas_coords = world_tilemap.get_cell_atlas_coords(_coords)
	if _atlas_coords == sketch_atlas_coords:
		if debug:
			print('      World cell ' + str(_coords) + ' IS sketched with atlas coords ' + str(_atlas_coords))
		return true
	else:
		if Vector2(_atlas_coords) == Vector2(-1,-1):
			print('      World cell ' + str(_coords) + ' Is NOT sketched')
			return false
		if debug:
			print('      World cell ' + str(_coords) + ' Is NOT sketched with atlas coords ' + str(_atlas_coords))
		return false
