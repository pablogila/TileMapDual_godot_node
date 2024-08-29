@tool
class_name TileMapDual
extends TileMapLayer

## TileMapLayer in the World grid, where the tiles are sketched.
## An offset of (-0.5,-0.5) tiles will be applied
## with respect to the World grid.
## Sketch here with the corresponding fully-filled tile
## from the standard tileset, indicated as sketch_atlas_coord.
@export var world_tilemap: TileMapLayer = null
## Click to update the tilemap inside the editor.
## Make sure that the Freeze option is not checked!
@export var update_in_editor: bool = false:
	set(value):
		update_tileset()
## Clean all the drawn tiles from the TileMapDual node.
@export var clean: bool = false:
	set(value):
		self.clear()
## Stop any incoming updates of the dual tilemap,
## freezing it in its current state.
@export var freeze: bool = false
## Print debug messages. Lots of them.
@export var debug: bool = false

## We will use a bit-wise logic, so that
## a summation over all sketched neighbours
## provides a unique key, that will be assigned
## to the corresponding tile from the Atlas
## through the NEIGHBOURS_TO_ATLAS dictionary.
enum location {
	TOP_LEFT  = 1,
	LOW_LEFT  = 2,
	TOP_RIGHT = 4,
	LOW_RIGHT = 8
	}

## Overlapping tiles from the World grid
## that a tile from the Dual grid has.
const NEIGHBOURS := {
	location.TOP_LEFT  : Vector2i(0,0),
	location.LOW_LEFT  : Vector2i(0,1),
	location.TOP_RIGHT : Vector2i(1,0),
	location.LOW_RIGHT : Vector2i(1,1)
	}

## Overlapping tiles from the World grid
## that a tile from the Dual grid has.
## To be used ONLY with isometric tilesets.
const NEIGHBOURS_ISOMETRIC := {
	location.TOP_LEFT  : Vector2i(0,0),
	location.LOW_LEFT  : Vector2i(0,1), # - (1,0)
	location.TOP_RIGHT : Vector2i(1,1), # - (1,0)
	location.LOW_RIGHT : Vector2i(0,2)
	}

## Dict to assign the Atlas coordinates from the
## summation over all sketched NEIGHBOURS.
## Follows the official 2x2 template.
############ SHOULD ALSO WORK FOR ISOMETRIC
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

## Coordinates for the fully-filled tile in the Atlas
## that will be used to sketch in the World grid.
## Defaults to the one in the standard Godot template.
## Only this tile will be considered for autotiling.
var full_tile: Vector2i = Vector2i(2,1)
## The opposed of full_tile.
## Used in-game to erase sketched tiles.
var empty_tile: Vector2i = Vector2i(0,3)
## Prevents checking the cells more than once
## when the entire tileset is being updated,
## which is indicated by checked_cells[0]=true.
## checked_cells[0]=false to overpass this check. 
var checked_cells: Array = [false]
## Track if it is isometric or not
var is_isometric = false


func _ready() -> void:
	if freeze:
		return
	
	if debug:
		print('Updating in-game is activated')
	
	if world_tilemap == null:
		if self.owner.is_class('TileMapDual'):
			world_tilemap = self.owner
	
	update_tileset()


## Update the entire tileset resource from the dual grid.
## Copies the tileset resource from the world grid,
## displaces itself by half a tile, and updates all tiles.
func update_tileset() -> void:
	if freeze:
		return
	
	if debug:
		print('tile_set.tile_shape = ' + str(world_tilemap.tile_set.tile_shape))
	
	self.tile_set = world_tilemap.tile_set
	if world_tilemap.tile_set.tile_shape == 1:
		is_isometric = true
		self.position.x = - self.tile_set.tile_size.x * 0
		self.position.y = - self.tile_set.tile_size.y * 0.5
	else:
		is_isometric = false
		self.position.x = - self.tile_set.tile_size.x * 0.5
		self.position.y = - self.tile_set.tile_size.y * 0.5
	_update_tiles()


## Update all displayed tiles from the dual grid.
## It will only process fully-filled tiles from the world grid.
func _update_tiles() -> void:
	if debug:
		print('Updating tiles....................')
	
	self.clear()
	checked_cells = [true]
	for _world_cell in world_tilemap.get_used_cells():
		if _is_world_tile_sketched(_world_cell):
			update_tile(_world_cell)
	# checked_cells will only be used when updating
	# the entire tilemap to avoid repeating checks.
	# This check is skipped when updating tiles individually.
	checked_cells = [false]

## Takes a world cell, and updates the
## overlapping tiles from the dual grid accordingly.
func update_tile(world_cell: Vector2i) -> void:
	if freeze:
		return
	
	if debug:
		print('  Updating displayed cells around world cell ' + str(world_cell) + '...')
	
	if is_isometric:
		_update_tile_isometric(world_cell)
		return
	
	# Calculate the overlapping cells from the dual grid and update them accordingly
	var _top_left = world_cell + NEIGHBOURS[location.TOP_LEFT]
	var _low_left = world_cell + NEIGHBOURS[location.LOW_LEFT]
	var _top_right = world_cell + NEIGHBOURS[location.TOP_RIGHT]
	var _low_right = world_cell + NEIGHBOURS[location.LOW_RIGHT]
	_update_displayed_tile(_top_left)
	_update_displayed_tile(_low_left)
	_update_displayed_tile(_top_right)
	_update_displayed_tile(_low_right)


func _update_displayed_tile(_display_cell: Vector2i) -> void:
	# Avoid updating cells more than necessary
	if checked_cells[0] == true:
		if _display_cell in checked_cells:
			return
		checked_cells.append(_display_cell)
	
	if debug:
		print('    Checking display tile ' + str(_display_cell) + '...')
	
	# INFO: To get the world cells from the dual grid, we apply the opposite vectors
	var _top_left = _display_cell - NEIGHBOURS[location.LOW_RIGHT]  # - (1,1)
	var _low_left = _display_cell - NEIGHBOURS[location.TOP_RIGHT]  # - (1,0)
	var _top_right = _display_cell - NEIGHBOURS[location.LOW_LEFT]  # - (0,1)
	var _low_right = _display_cell - NEIGHBOURS[location.TOP_LEFT]  # - (0,0)
	
	# We perform a bitwise summation over the sketched neighbours
	var _tile_key: int = 0
	if _is_world_tile_sketched(_top_left):
		_tile_key += location.TOP_LEFT
	if _is_world_tile_sketched(_low_left):
		_tile_key += location.LOW_LEFT
	if _is_world_tile_sketched(_top_right):
		_tile_key += location.TOP_RIGHT
	if _is_world_tile_sketched(_low_right):
		_tile_key += location.LOW_RIGHT
	
	var _coords_atlas: Vector2i = NEIGHBOURS_TO_ATLAS[_tile_key]
	self.set_cell(_display_cell, 0, _coords_atlas)
	if debug:
		print('    Display tile ' + str(_display_cell) + ' updated with key ' + str(_tile_key))


## Takes a world cell, and updates the
## overlapping tiles from the dual grid accordingly.
## Used automatically for isometric grids.
func _update_tile_isometric(_world_cell: Vector2i) -> void:
	# If _world_cell.y is even, displace by (-1,0) the low_left and top_right cells
	var isometric_fix: Vector2i = Vector2i(0,0)
	if abs(_world_cell.y) % 2 == 0:
		isometric_fix = Vector2i(-1,0)
	
	# CAUTION: I am not going to explain how does the isometric fix works. It does. I need a coffee.
	var _top_left = _world_cell + NEIGHBOURS_ISOMETRIC[location.TOP_LEFT]
	var _low_left = _world_cell + NEIGHBOURS_ISOMETRIC[location.LOW_LEFT] + isometric_fix
	var _top_right = _world_cell + NEIGHBOURS_ISOMETRIC[location.TOP_RIGHT] + isometric_fix
	var _low_right = _world_cell + NEIGHBOURS_ISOMETRIC[location.LOW_RIGHT]
	_update_displayed_tile_isometric(_top_left)
	_update_displayed_tile_isometric(_low_left)
	_update_displayed_tile_isometric(_top_right)
	_update_displayed_tile_isometric(_low_right)


func _update_displayed_tile_isometric(_display_cell: Vector2i) -> void:
	# Avoid updating cells more than necessary
	if checked_cells[0] == true:
		if _display_cell in checked_cells:
			return
		checked_cells.append(_display_cell)
	
	if debug:
		print('    Checking display tile ' + str(_display_cell) + '...')
	
	# If _display_cell.y is odd, displace by (+1,0) the low_left and top_right cells
	var isometric_fix: Vector2i = Vector2i(0,0)
	if abs(_display_cell.y) % 2 == 1:
		isometric_fix = Vector2i(1,0)
	
	# INFO: Same as with squares, opposite vectors apply
	# CAUTION: The coffee thing
	var _top_left: Vector2i = _display_cell - NEIGHBOURS_ISOMETRIC[location.LOW_RIGHT]  # - (1,1)
	var _low_left: Vector2i = _display_cell - NEIGHBOURS_ISOMETRIC[location.TOP_RIGHT] + isometric_fix  # - (1,0) or (0,0)
	var _top_right: Vector2i = _display_cell - NEIGHBOURS_ISOMETRIC[location.LOW_LEFT] + isometric_fix  # - (1,1) or (2,1)
	var _low_right: Vector2i = _display_cell - NEIGHBOURS_ISOMETRIC[location.TOP_LEFT]  # - (0,2)
	
	# We perform a bitwise summation over the sketched neighbours
	var _tile_key: int = 0
	if _is_world_tile_sketched(_top_left):
		_tile_key += location.TOP_LEFT
	if _is_world_tile_sketched(_low_left):
		_tile_key += location.LOW_LEFT
	if _is_world_tile_sketched(_top_right):
		_tile_key += location.TOP_RIGHT
	if _is_world_tile_sketched(_low_right):
		_tile_key += location.LOW_RIGHT
	
	var _coords_atlas: Vector2i = NEIGHBOURS_TO_ATLAS[_tile_key]
	self.set_cell(_display_cell, 0, _coords_atlas)
	if debug:
		print('    Display tile ' + str(_display_cell) + ' updated with key ' + str(_tile_key))


func _is_world_tile_sketched(_world_cell: Vector2i) -> bool:
	var _atlas_coords = world_tilemap.get_cell_atlas_coords(_world_cell)
	if _atlas_coords == full_tile:
		if debug:
			print('      World cell ' + str(_world_cell) + ' IS sketched with atlas coords ' + str(_atlas_coords))
		return true
	else:
		# If the cell is empty, get_cell_atlas_coords() returns (-1,-1)
		if Vector2(_atlas_coords) == Vector2(-1,-1):
			if debug:
				print('      World cell ' + str(_world_cell) + ' Is EMPTY')
			return false
		if debug:
			print('      World cell ' + str(_world_cell) + ' Is NOT sketched with atlas coords ' + str(_atlas_coords))
		return false


## Public method to add a tile in a given World cell
func fill_tile(world_cell) -> void:
	if freeze:
		return
	world_tilemap.set_cell(world_cell, 0, full_tile)
	update_tile(world_cell)


## Public method to erase a tile in a given World cell
func erase_tile(world_cell) -> void:
	if freeze:
		return
	world_tilemap.set_cell(world_cell, 0, empty_tile)
	update_tile(world_cell)
