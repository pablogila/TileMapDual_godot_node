@tool
class_name TileMapDual
extends TileMapLayer

## TileMapLayer in the World grid, where the tiles are sketched.
## An offset of (-0.5,-0.5) tiles will be applied
## with respect to the World grid.
## Sketch with the corresponding sketch_atlas_coord.
@export var sketch_tilemap: TileMapLayer = null
## Clean all the tiles from the TileMapDual node.
@export var clean: bool = false:
	set(value):
		self.clear()
## Click to update the tilemap inside the editor.
@export var update_in_editor: bool = false:
	set(value):
		update_tilemap()
## Update and modify the tileset in-game via sketch_tilemap.changed() signal.
## Disable it to freeze the tilemap in its current state.
@export var update_in_game: bool = false
## Print debug messages. Lots of them.
@export var debug: bool = false

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
	 0: Vector2i(0,3),
	 1: Vector2i(3,3),
	 2: Vector2i(0,0),
	 3: Vector2i(3,2),
	 4: Vector2i(0,2),
	 5: Vector2i(1,2),
	 6: Vector2i(2,3),
	 7: Vector2i(3,1),
	 8: Vector2i(1,3),
	 9: Vector2i(0,1),
	10: Vector2i(3,0),
	11: Vector2i(2,0),
	12: Vector2i(1,0),
	13: Vector2i(2,2),
	14: Vector2i(1,1),
	15: Vector2i(2,1)
	}

## Coordinates for the tile in the Atlas
## that will be used to sketch in-editor in the World TileMapLayer.
## Defaults to the one in the standard Godot template.
## Only this tile will be used for autotiling.
var sketch_atlas_coords: Vector2i = Vector2i(2,1)
## The opposed of sketch_atlas_coords.
## Used in-game to erase sketched tiles.
var empty_atlas_coords: Vector2i = Vector2i(0,3)
## Prevents checking the cells more than once
var checked_cells: Array = []
## Isometric or not
var is_isometric = false


func _ready() -> void:
	if update_in_game:
		if debug:
			print('Updating in-game is activated')
		sketch_tilemap.changed.connect(update_tilemap)
		update_tilemap()


func update_tilemap() -> void:
	if debug:
		print('tile_set.tile_shape = ' + str(sketch_tilemap.tile_set.tile_shape))
	
	self.tile_set = sketch_tilemap.tile_set
	if sketch_tilemap.tile_set.tile_shape == 1:  # Isself.position.y = - self.tile_set.tile_size.y * 0.5ometric tiles
		is_isometric = true
		self.position.x = - self.tile_set.tile_size.x * 0
		self.position.y = - self.tile_set.tile_size.y * 0.5
	else:
		is_isometric = false
		self.position.x = - self.tile_set.tile_size.x * 0.5
		self.position.y = - self.tile_set.tile_size.y * 0.5
	self.clear()
	_update_tiles()


func _update_tiles() -> void:
	checked_cells = []
	if debug:
		print('Updating tiles....................')
	for _world_cell in sketch_tilemap.get_used_cells():
		if _is_world_tile_sketched(_world_cell):
			if is_isometric:
				_update_tiles_around_world_cell_isometric(_world_cell)
			else:
				_update_tiles_around_world_cell(_world_cell)


## TO-IMPLEMENT
func _update_tiles_around_world_cell_isometric(_world_cell: Vector2i) -> void:
	_update_tiles_around_world_cell(_world_cell)
	# _update_cell_isometric()

func _update_tiles_around_world_cell(_world_cell: Vector2i) -> void:
	if debug:
		print('  Updating displayed cells around world cell ' + str(_world_cell) + '...')
	var _top_left = _world_cell + NEIGHBOURS[location.TOP_LEFT]
	var _low_left = _world_cell + NEIGHBOURS[location.LOW_LEFT]
	var _top_right = _world_cell + NEIGHBOURS[location.TOP_RIGHT]
	var _low_right = _world_cell + NEIGHBOURS[location.LOW_RIGHT]
	_update_cell(_top_left)
	_update_cell(_low_left)
	_update_cell(_top_right)
	_update_cell(_low_right)


func _update_cell(_cell: Vector2i) -> void:
	# Avoid upgrading cells more than necessary
	if _cell in checked_cells:
		return
	checked_cells.append(_cell)
	
	if debug:
		print('    Checking display tile ' + str(_cell) + '...')
	
	var _top_left = _cell - NEIGHBOURS[location.LOW_RIGHT]
	var _low_left = _cell - NEIGHBOURS[location.TOP_RIGHT]
	var _top_right = _cell - NEIGHBOURS[location.LOW_LEFT]
	var _low_right = _cell - NEIGHBOURS[location.TOP_LEFT]
	
	var _coords_atlas: Vector2i
	var _tile_key: int = 0
	if _is_world_tile_sketched(_top_left):
		_tile_key += location.TOP_LEFT
	if _is_world_tile_sketched(_low_left):
		_tile_key += location.LOW_LEFT
	if _is_world_tile_sketched(_top_right):
		_tile_key += location.TOP_RIGHT
	if _is_world_tile_sketched(_low_right):
		_tile_key += location.LOW_RIGHT
	
	_coords_atlas = NEIGHBOURS_TO_ATLAS[_tile_key]
	self.set_cell(_cell, 0, _coords_atlas)
	if debug:
		print('    Display tile ' + str(_cell) + ' updated with key ' + str(_tile_key))


func _is_world_tile_sketched(_world_cell: Vector2i) -> bool:
	var _atlas_coords = sketch_tilemap.get_cell_atlas_coords(_world_cell)
	if _atlas_coords == sketch_atlas_coords:
		if debug:
			print('      World cell ' + str(_world_cell) + ' IS sketched with atlas coords ' + str(_atlas_coords))
		return true
	else:
		if Vector2(_atlas_coords) == Vector2(-1,-1):
			if debug:
				print('      World cell ' + str(_world_cell) + ' Is EMPTY')
			return false
		if debug:
			print('      World cell ' + str(_world_cell) + ' Is NOT sketched with atlas coords ' + str(_atlas_coords))
		return false
