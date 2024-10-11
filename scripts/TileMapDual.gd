@tool
class_name TileMapDual
extends TileMapLayer


var display_tilemap: TileMapLayer = null
var _filled_cells = []
var _emptied_cells = []
## Coordinates for the fully-filled tile in the Atlas that
## will be used to sketch in the World grid.
## Only this tile will be considered for autotiling.
var full_tile: Vector2i = Vector2i(2,1)
## The opposed of full_tile. Used to erase sketched tiles.
var empty_tile: Vector2i = Vector2i(0,3)
## Prevents checking the cells more than once when the entire tileset
## is being updated, which is indicated by _checked_cells[0]=true.
## _checked_cells[0]=false will overpass this check. 
var _checked_cells: Array = [false]
var is_isometric: bool = false
var _atlas_id: int

## We will use a bit-wise logic, so that a summation over all sketched
## neighbours provides a unique key, assigned to the corresponding
## tile from the Atlas through the NEIGHBOURS_TO_ATLAS dictionary.
enum _location {
	TOP_LEFT  = 1,
	LOW_LEFT  = 2,
	TOP_RIGHT = 4,
	LOW_RIGHT = 8
	}

enum _direction {
	TOP,
	LEFT,
	BOTTOM,
	RIGHT,
	BOTTOM_RIGHT,
	TOP_LEFT,
	}

## Overlapping tiles from the World grid
## that a tile from the Dual grid has.
const _NEIGHBORS := {
	_direction.TOP  : TileSet.CellNeighbor.CELL_NEIGHBOR_TOP_SIDE,
	_direction.LEFT : TileSet.CellNeighbor.CELL_NEIGHBOR_LEFT_SIDE,
	_direction.RIGHT : TileSet.CellNeighbor.CELL_NEIGHBOR_RIGHT_SIDE,
	_direction.BOTTOM  : TileSet.CellNeighbor.CELL_NEIGHBOR_BOTTOM_SIDE,
	_direction.TOP_LEFT  : TileSet.CellNeighbor.CELL_NEIGHBOR_TOP_LEFT_CORNER,
	_direction.BOTTOM_RIGHT : TileSet.CellNeighbor.CELL_NEIGHBOR_BOTTOM_RIGHT_CORNER
	}

## Overlapping tiles from the World grid
## that a tile from the Dual grid has.
## To be used ONLY with isometric tilesets.
## CellNighbors are literal, even for Isometric
const _NEIGHBORS_ISOMETRIC := {
	_direction.TOP : TileSet.CellNeighbor.CELL_NEIGHBOR_TOP_RIGHT_SIDE,
	_direction.LEFT : TileSet.CellNeighbor.CELL_NEIGHBOR_TOP_LEFT_SIDE,
	_direction.RIGHT : TileSet.CellNeighbor.CELL_NEIGHBOR_BOTTOM_RIGHT_SIDE,
	_direction.BOTTOM  : TileSet.CellNeighbor.CELL_NEIGHBOR_BOTTOM_LEFT_SIDE,
	_direction.TOP_LEFT  : TileSet.CellNeighbor.CELL_NEIGHBOR_TOP_CORNER,
	_direction.BOTTOM_RIGHT : TileSet.CellNeighbor.CELL_NEIGHBOR_BOTTOM_CORNER
	}

## Dict to assign the Atlas coordinates from the
## summation over all sketched NEIGHBOURS.
## Follows the official 2x2 template.
## Works for isometric as well.
const _NEIGHBORS_TO_ATLAS: Dictionary = {
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


func _ready() -> void:
	if Engine.is_editor_hint():
		set_process(true)
	else: # Run in-game using signals for better performance
		set_process(false)
		self.changed.connect(_update_tileset, 1)


func _process(_delta): # Only used inside the editor
	if not self.tile_set:
		return
	call_deferred('_update_tileset')


## Set the dual grid as a child of TileMapDual.
func _set_display_tilemap() -> void:
	if not self.tile_set:
		return
	# Make TileMapDual invisible without disabling it
	if not self.material:
		self.material = CanvasItemMaterial.new()
		self.material.light_mode = CanvasItemMaterial.LightMode.LIGHT_MODE_LIGHT_ONLY
	# Add the display TileMapLayer
	if not get_node_or_null('WorldTileMap'):
		display_tilemap = TileMapLayer.new()
		display_tilemap.name = "WorldTileMap"
		add_child(display_tilemap)
	# Both tilemaps must be the same
	if display_tilemap.tile_set != self.tile_set:
		display_tilemap.tile_set = self.tile_set
	# Displace the display TileMapLayer
	if self.tile_set.tile_shape == 1:
		is_isometric = true
		display_tilemap.position.x = - self.tile_set.tile_size.x * 0
		display_tilemap.position.y = - self.tile_set.tile_size.y * 0.5
	else:
		is_isometric = false
		display_tilemap.position.x = - self.tile_set.tile_size.x * 0.5
		display_tilemap.position.y = - self.tile_set.tile_size.y * 0.5


## Update the entire tileset.
func update_full_tileset() -> void:
	if display_tilemap == null:
		_set_display_tilemap()
	display_tilemap.clear()
	_checked_cells = [true]
	for _cell in self.get_used_cells():
		if _is_world_tile_sketched(_cell):
			update_tile(_cell)
		elif _is_world_tile_sketched(_cell) == 0:
			update_tile(_cell)
	_checked_cells = [false]
	# _checked_cells is only used when updating
	# the whole tilemap to avoid repeating checks.
	# This is skipped when updating tiles individually.


## Update only the very specific tiles that have changed.
func _update_tileset() -> void:
	if display_tilemap == null:
		_set_display_tilemap()
	if display_tilemap.tile_set != self.tile_set:
		update_full_tileset()
		return
	var _new_emptied_cells: Array = get_used_cells_by_id(-1, empty_tile)
	var _new_filled_cells: Array = get_used_cells_by_id(-1, full_tile)
	var _changed_cells: Array = intersect_arrays(
		exclude_arrays(_emptied_cells, _new_emptied_cells),
		exclude_arrays(_filled_cells, _new_filled_cells)
		)
	_emptied_cells = _new_emptied_cells
	_filled_cells = _new_filled_cells
	for _cell in _changed_cells:
		update_tile(_cell)


## Return the values that are not shared between the arrays
func exclude_arrays(a: Array, b: Array) -> Array:
	var result = a.duplicate()
	for item in b:
		if result.has(item):
			result.erase(item)
		else:
			result.append(item)
	return result


## Merge both arrays without duplicates
func intersect_arrays(a: Array, b: Array) -> Array:
	var result: Array = a.duplicate()
	for item in b:
		if not result.has(item):
			result.append(item)
	return result


## Takes a cell, and updates the overlapping tiles from the dual grid accordingly.
func update_tile(world_cell: Vector2i) -> void:
	# Update the atlas_id if the cell is not empty
#	var id = self.get_cell_source_id(world_cell)
#	if id != -1:
#		_atlas_id = id
	_atlas_id = self.get_cell_source_id(world_cell)
	
	var __NEIGHBORS = _NEIGHBORS_ISOMETRIC if is_isometric else _NEIGHBORS
	var _top_left = world_cell
	var _low_left = display_tilemap.get_neighbor_cell(world_cell, __NEIGHBORS[_direction.BOTTOM])
	var _top_right = display_tilemap.get_neighbor_cell(world_cell, __NEIGHBORS[_direction.RIGHT])
	var _low_right = display_tilemap.get_neighbor_cell(world_cell, __NEIGHBORS[_direction.BOTTOM_RIGHT])
	_update_displayed_tile(_top_left)
	_update_displayed_tile(_low_left)
	_update_displayed_tile(_top_right)
	_update_displayed_tile(_low_right)


func _update_displayed_tile(_display_cell: Vector2i) -> void:
	# Avoid updating cells more than necessary
	if _checked_cells[0] == true:
		if _display_cell in _checked_cells:
			return
		_checked_cells.append(_display_cell)
	
	var __NEIGHBORS = _NEIGHBORS_ISOMETRIC if is_isometric else _NEIGHBORS
	var _top_left = display_tilemap.get_neighbor_cell(_display_cell, __NEIGHBORS[_direction.TOP_LEFT])
	var _low_left = display_tilemap.get_neighbor_cell(_display_cell, __NEIGHBORS[_direction.LEFT])
	var _top_right = display_tilemap.get_neighbor_cell(_display_cell, __NEIGHBORS[_direction.TOP])
	var _low_right = _display_cell
	
	# We perform a bitwise summation over the sketched neighbours
	var _tile_key: int = 0
	if _is_world_tile_sketched(_top_left):
		_tile_key += _location.TOP_LEFT
	if _is_world_tile_sketched(_low_left):
		_tile_key += _location.LOW_LEFT
	if _is_world_tile_sketched(_top_right):
		_tile_key += _location.TOP_RIGHT
	if _is_world_tile_sketched(_low_right):
		_tile_key += _location.LOW_RIGHT
	
	var _coords_atlas: Vector2i = _NEIGHBORS_TO_ATLAS[_tile_key]
	display_tilemap.set_cell(_display_cell, _atlas_id, _coords_atlas)


func _is_world_tile_sketched(_world_cell: Vector2i):
	var _atlas_coords = get_cell_atlas_coords(_world_cell)
	if _atlas_coords == full_tile:
		return true
	elif _atlas_coords == empty_tile:
		return 0
	return false


## Public method to add a tile in a given World cell
func fill_tile(cell, atlas_id=0) -> void:
	set_cell(cell, atlas_id, full_tile)
	update_tile(cell)


## Public method to erase a tile in a given World cell
func erase_tile(cell, atlas_id=0) -> void:
	set_cell(cell, atlas_id, empty_tile)
	update_tile(cell)
