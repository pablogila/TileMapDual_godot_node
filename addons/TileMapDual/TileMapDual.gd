@tool
@icon('TileMapDual.svg')
class_name TileMapDual
extends TileMapLayer


func _ready() -> void:
	#_create_display_tilemaps()
	if Engine.is_editor_hint() and false:
		set_process(true)
	else: # Run in-game using signals for better performance
		set_process(false)
		changed.connect(_changed, 1)


## Sets up the Dual-Grid illusion.
## Called on ready.
func _make_self_invisible() -> void:
	material = CanvasItemMaterial.new()
	material.light_mode = CanvasItemMaterial.LightMode.LIGHT_MODE_LIGHT_ONLY


func _process(_delta) -> void: # Only used inside the editor
	call_deferred('_changed')


func _input(event: InputEvent) -> void:
	print(event)


## Called by signals when the tileset changes,
## or by _process inside the editor.
func _changed() -> void:
	_update_full_tileset()
	_update_tilemap()


# TODO: use signals to tell when something has been added or deleted
signal tileset_resized(new_size: Vector2i)
signal tileset_reshaped(new_grid: Display.Grid)
signal tileset_deleted
signal tileset_added
signal atlas_added(tile_set: TileSet, source_id: int, atlas: TileSetAtlasSource)
signal terrains_changed(tile_set: TileSet)
signal world_tiles_changed(changed: Array[Vector2i])

var _cached_tile_set = null
var _display: Display = null
func _update_full_tileset() -> void:
	# Check if tile_set has been added, replaced, or deleted
	if tile_set == _cached_tile_set:
		return
	print('tile set replaced')
	if _cached_tile_set != null:
		_cached_tile_set.changed.disconnect(_changed_tile_set)
		_display.queue_free()
		#_update_full_tilemap()
	if tile_set != null:
		_display = Display.new(tile_set)
		add_child(_display)
		tile_set.changed.connect(_changed_tile_set, 1)
		tile_set.emit_changed()
	_cached_tile_set = tile_set


var _cached_source_count: int = 0
var _cached_shape: Display.Grid
func _changed_tile_set() -> void:
	print('tile set changed')
	_update_tile_set_atlases()


## Configures all tile set atlases
# TODO: detect automatic tile creation
var _cached_sids := Set.new()
func _update_tile_set_atlases():
	# Update all tileset sources
	var source_count := tile_set.get_source_count()
	var terrain_set_count := tile_set.get_terrain_sets_count()
	# Only if an asset was added or removed
	if _cached_source_count == source_count:
		return
	_cached_source_count = source_count
	
	print('actually changing')
	
	# Process the new atlases in the TileSet
	var sids := Set.new()
	for i in source_count:
		var sid: int = tile_set.get_source_id(i)
		sids.insert(sid)
		print('checking')
		if _cached_sids.has(sid):
			continue
		var source: TileSetSource = tile_set.get_source(sid)
		if source is not TileSetAtlasSource:
			push_warning(
				"Non-Atlas TileSet found at index %i, source id %i.\n" % [i, source] +
				"Dual Grids only support Atlas TileSets."
			)
			continue
		var atlas: TileSetAtlasSource = source
		print('writing')
		TerrainDual.write_default_preset(tile_set, atlas)
	_cached_sids = sids

# TODO: write the map diff algorithm and connect it to the display dual grid neighbor thing
var display_tilemaps: Array[TileMapLayer] = []

var _cached_cells := Set.new()
"""
		var _new_emptied_cells: Array = parent.get_used_cells_by_id(-1, empty_tile)
		var _new_filled_cells: Array = parent.get_used_cells_by_id(-1, full_tile)
"""
func _update_tilemap() -> void:
	#var current_cells = _compute_current_cells()
	pass

"""
## Update the size and shape of the tileset, displacing the display TileMapLayer accordingly.
func _update_geometry() -> void:
	var size := Vector2(self.tile_set.tile_size)
	var displacements = GEOMETRY_DISPLACEMENTS[self.tile_set.tile_shape]
	for i in display_tilemaps.size():
		if i < displacements.size():
			display_tilemaps[i].position = size * displacements[i]
		else:
			display_tilemaps[i].enabled = false


## Update every cell in the entire tilemap.
func _update_full_tilemap() -> void:
	#_cached_cells = {}
	#_update_changed_cells()
	pass


## Update only the very specific tiles that have changed.
## Much more efficient than update_full_tilemap.
func _update_tilemap() -> void:
	var _new_emptied_cells: Array = get_used_cells_by_id(-1, empty_tile)
	var _new_filled_cells: Array = get_used_cells_by_id(-1, full_tile)
	# TODO: convert arrays into changed cells
	_update_changed_cells()


func _update_changed_cells(_changed_cells) -> void:
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

	# HACK: redirect to hex grid algorithm
	#if self.tile_set.tile_shape == TileSet.TileShape.TILE_SHAPE_HEXAGON:
		
	
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
"""
