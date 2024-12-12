@tool
@icon('TileMapDual.svg')
class_name TileMapDual
extends TileMapLayer


var display_tilemap: TileMapLayer = null
## When self.tile_set is set to null,
## the _changed_tileset() function is disconnected through this variable.
var _tile_set: TileSet = null
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
var _atlas_id: int

## We will use a bit-wise logic, so that a summation over all sketched
## neighbours provides a unique key, assigned to the corresponding
## tile from the Atlas through the NEIGHBOURS_TO_ATLAS dictionary.
enum _location {
	TOP_LEFT  = 1,
	LOW_LEFT  = 2,
	TOP_RIGHT = 4,
	LOW_RIGHT = 8,
	}

enum _direction {
	TOP,
	LEFT,
	BOTTOM,
	RIGHT,
	BOTTOM_LEFT,
	BOTTOM_RIGHT,
	TOP_LEFT,
	TOP_RIGHT,
	}

## Overlapping tiles from the World grid
## that a tile from the Dual grid has.
const _NEIGHBORS := {
	TileSet.TileShape.TILE_SHAPE_SQUARE : {
		_direction.TOP : TileSet.CellNeighbor.CELL_NEIGHBOR_TOP_SIDE,
		_direction.LEFT : TileSet.CellNeighbor.CELL_NEIGHBOR_LEFT_SIDE,
		_direction.RIGHT : TileSet.CellNeighbor.CELL_NEIGHBOR_RIGHT_SIDE,
		_direction.BOTTOM : TileSet.CellNeighbor.CELL_NEIGHBOR_BOTTOM_SIDE,
		_direction.TOP_LEFT : TileSet.CellNeighbor.CELL_NEIGHBOR_TOP_LEFT_CORNER,
		_direction.TOP_RIGHT : TileSet.CellNeighbor.CELL_NEIGHBOR_TOP_RIGHT_CORNER,
		_direction.BOTTOM_LEFT : TileSet.CellNeighbor.CELL_NEIGHBOR_BOTTOM_LEFT_CORNER,
		_direction.BOTTOM_RIGHT : TileSet.CellNeighbor.CELL_NEIGHBOR_BOTTOM_RIGHT_CORNER
		},
	TileSet.TileShape.TILE_SHAPE_ISOMETRIC : {
		_direction.TOP : TileSet.CellNeighbor.CELL_NEIGHBOR_TOP_RIGHT_SIDE,
		_direction.LEFT : TileSet.CellNeighbor.CELL_NEIGHBOR_TOP_LEFT_SIDE,
		_direction.RIGHT : TileSet.CellNeighbor.CELL_NEIGHBOR_BOTTOM_RIGHT_SIDE,
		_direction.BOTTOM : TileSet.CellNeighbor.CELL_NEIGHBOR_BOTTOM_LEFT_SIDE,
		_direction.TOP_LEFT : TileSet.CellNeighbor.CELL_NEIGHBOR_TOP_CORNER,
		_direction.TOP_RIGHT : TileSet.CellNeighbor.CELL_NEIGHBOR_RIGHT_CORNER,
		_direction.BOTTOM_LEFT : TileSet.CellNeighbor.CELL_NEIGHBOR_LEFT_CORNER,
		_direction.BOTTOM_RIGHT : TileSet.CellNeighbor.CELL_NEIGHBOR_BOTTOM_CORNER
		},
	TileSet.TileShape.TILE_SHAPE_HEXAGON : {
		# TODO
		}
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
	_create_display_tilemap()
	if Engine.is_editor_hint():
		set_process(true)
	else: # Run in-game using signals for better performance
		set_process(false)
		self.changed.connect(_changed, 1)


func _process(_delta) -> void: # Only used inside the editor
	if not self.tile_set:
		return
	call_deferred('_changed')


## Called by signals when the tileset changes,
## or by _process inside the editor.
func _changed() -> void:
	_update_full_tileset()
	_update_tilemap()


## Sets up the Dual-Grid illusion.
## Called on ready.
func _create_display_tilemap() -> void:
	# Add the display TileMapLayer
	display_tilemap = TileMapLayer.new()
	display_tilemap.name = "WorldTileMap"
	add_child(display_tilemap)
	# Make TileMapDual invisible without disabling it
	self.material = CanvasItemMaterial.new()
	self.material.light_mode = CanvasItemMaterial.LightMode.LIGHT_MODE_LIGHT_ONLY


## Update the entire tileset, including geometry and tilemap data.
func _update_full_tileset() -> void:
	# Check if tile_set has been added or replaced
	# For some reason I cannot detect if it has been deleted
	if self.tile_set and self.tile_set != _tile_set:
		if _tile_set:
			_tile_set.changed.disconnect(_changed_tileset)
		_tile_set = self.tile_set
		self.tile_set.changed.connect(_changed_tileset, 1)
		self.tile_set.emit_changed()



## Called on tile_set.changed.
func _changed_tileset() -> void:
	_update_tileset_data()


## Updates the data within the tileset.
func _update_tileset_data() -> void:
	display_tilemap.tile_set = self.tile_set.duplicate()
	_update_geometry()


## Update the size and shape of the tileset, displacing the display TileMapLayer accordingly.
func _update_geometry() -> void:
	var offset := Vector2(self.tile_set.tile_size) * -0.5
	if self.tile_set.tile_shape == TileSet.TileShape.TILE_SHAPE_ISOMETRIC:
		offset.x = 0
	display_tilemap.position = offset


## Update every cell in the entire tilemap.
func _update_full_tilemap() -> void:
	# Process all the cells in the map
	_checked_cells = [true]
	for _cell in self.get_used_cells():
		if _is_world_tile_sketched(_cell) == 1 or _is_world_tile_sketched(_cell) == 0:
			update_tile(_cell)
	_checked_cells = [false]
	# _checked_cells is only used when updating
	# the whole tilemap to avoid repeating checks.
	# This is skipped when updating tiles individually.


## Update only the very specific tiles that have changed.
## Much more efficient than update_full.
func _update_tilemap() -> void:
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


## Merge two arrays without duplicates
func intersect_arrays(a: Array, b: Array) -> Array:
	var result: Array = a.duplicate()
	for item in b:
		if not result.has(item):
			result.append(item)
	return result


## Takes a cell, and updates the overlapping tiles from the dual grid accordingly.
func update_tile(world_cell: Vector2i, recurse: bool = true) -> void:
	_atlas_id = self.get_cell_source_id(world_cell)

	# to not fall in a recursive loop because of a large space of emptiness in the map
	if (!recurse and _atlas_id == -1):
		return


	var __NEIGHBORS = _NEIGHBORS[self.tile_set.tile_shape]
	var _top_left = world_cell
	var _low_left = display_tilemap.get_neighbor_cell(world_cell, __NEIGHBORS[_direction.BOTTOM])
	var _top_right = display_tilemap.get_neighbor_cell(world_cell, __NEIGHBORS[_direction.RIGHT])
	var _low_right = display_tilemap.get_neighbor_cell(world_cell, __NEIGHBORS[_direction.BOTTOM_RIGHT])
	_update_displayed_tile(_top_left)
	_update_displayed_tile(_low_left)
	_update_displayed_tile(_top_right)
	_update_displayed_tile(_low_right)

	# if atlas id is -1 the tile is empty, so to have a good rendering we need to update surroundings
	if (_atlas_id == -1):
		update_tile(self.get_neighbor_cell(world_cell, __NEIGHBORS[_direction.LEFT]), false)
		update_tile(self.get_neighbor_cell(world_cell, __NEIGHBORS[_direction.TOP_LEFT]), false)
		update_tile(self.get_neighbor_cell(world_cell, __NEIGHBORS[_direction.TOP]), false)
		update_tile(self.get_neighbor_cell(world_cell, __NEIGHBORS[_direction.TOP_RIGHT]), false)
		update_tile(self.get_neighbor_cell(world_cell, __NEIGHBORS[_direction.RIGHT]), false)
		update_tile(self.get_neighbor_cell(world_cell, __NEIGHBORS[_direction.BOTTOM_RIGHT]), false)
		update_tile(self.get_neighbor_cell(world_cell, __NEIGHBORS[_direction.BOTTOM]), false)
		update_tile(self.get_neighbor_cell(world_cell, __NEIGHBORS[_direction.BOTTOM_LEFT]), false)


func _update_displayed_tile(_display_cell: Vector2i) -> void:
	# Avoid updating cells more than necessary
	if _checked_cells[0] == true:
		if _display_cell in _checked_cells:
			return
		_checked_cells.append(_display_cell)

	var __NEIGHBORS = _NEIGHBORS[self.tile_set.tile_shape]
	var _top_left = display_tilemap.get_neighbor_cell(_display_cell, __NEIGHBORS[_direction.TOP_LEFT])
	var _low_left = display_tilemap.get_neighbor_cell(_display_cell, __NEIGHBORS[_direction.LEFT])
	var _top_right = display_tilemap.get_neighbor_cell(_display_cell, __NEIGHBORS[_direction.TOP])
	var _low_right = _display_cell

	# We perform a bitwise summation over the sketched neighbours
	var _tile_key: int = 0
	if _is_world_tile_sketched(_top_left) == 1:
		_tile_key += _location.TOP_LEFT
	if _is_world_tile_sketched(_low_left) == 1:
		_tile_key += _location.LOW_LEFT
	if _is_world_tile_sketched(_top_right) == 1:
		_tile_key += _location.TOP_RIGHT
	if _is_world_tile_sketched(_low_right) == 1:
		_tile_key += _location.LOW_RIGHT

	var _coords_atlas: Vector2i = _NEIGHBORS_TO_ATLAS[_tile_key]
	display_tilemap.set_cell(_display_cell, _atlas_id, _coords_atlas)


## Return -1 if the cell is empty, 0 if sketched with the empty tile,
## and 1 if it is sketched with the fully-filled tile.
func _is_world_tile_sketched(_world_cell: Vector2i) -> int:
	var _atlas_coords = get_cell_atlas_coords(_world_cell)
	if _atlas_coords == full_tile:
		return 1
	elif _atlas_coords == empty_tile:
		return 0
	return -1


## Public method to add and remove tiles, as
## TileMapDual.draw(cell, tile, atlas_id).
## 'cell' is a vector with the cell position.
## 'tile' is 1 to draw the full tile (default), 0 to draw the empty tile,
## and -1 to completely remove the tile.
## 'atlas_id' is the atlas id of the tileset to modify, 0 by default.
## This method replaces the deprecated 'fill_tile' and 'erase_tile' methods.
func draw(cell: Vector2i, tile: int = 1, atlas_id: int = 0) -> void:
	var tile_to_use: Vector2i
	if tile == 1:
		tile_to_use = full_tile
	if tile == 0:
		tile_to_use = empty_tile
	if tile == -1:
		tile_to_use = Vector2i(-1, -1)
		atlas_id = -1
	set_cell(cell, atlas_id, tile_to_use)
	update_tile(cell)
