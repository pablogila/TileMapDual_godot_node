class_name DisplayLayer
extends TileMapLayer


var dual_to_display: Array
var display_to_dual: Array
var offset: Vector2
var _tileset_watcher: TileSetWatcher
var _terrain: TerrainDual.TerrainLayer
func _init(
	tileset_watcher: TileSetWatcher,
	fields: Dictionary,
	layer: TerrainDual.TerrainLayer
) -> void:
	#print('initializing Layer...')
	tile_set = tileset_watcher.tile_set
	dual_to_display = fields.dual_to_display
	display_to_dual = fields.display_to_dual
	offset = fields.offset
	_tileset_watcher = tileset_watcher
	_terrain = layer
	tileset_watcher.tileset_resized.connect(reposition, 1)
	reposition()


func update_tiles_all(cache: Display.CellCache) -> void:
	update_tiles(cache, cache.cells.keys())


func update_tiles(cache: Display.CellCache, updated_cells: Array) -> void:
	#push_warning('updating tiles')
	var to_update := Set.new()
	for path: Array in dual_to_display:
		for cell: Vector2i in updated_cells:
			cell = follow_path(cell, path)
			if to_update.insert(cell):
				update_tile(cache, cell)


func update_tile(cache: Display.CellCache, cell: Vector2i) -> void:
	var get_cell_at_path := func(path): return get_terrain_at(cache, follow_path(cell, path))
	var normalize_terrain := func(terrain): return terrain if terrain != -1 else 0
	var true_neighborhood := display_to_dual.map(get_cell_at_path)
	var is_empty := true_neighborhood.all(func(terrain): return terrain == -1)
	var terrain_neighborhood = true_neighborhood.map(normalize_terrain)
	var invalid_neighborhood = terrain_neighborhood not in _terrain.rules
	if is_empty or invalid_neighborhood:
		erase_cell(cell)
		return
	var mapping: Dictionary = _terrain.rules[terrain_neighborhood]
	var sid: int = mapping.sid
	var tile: Vector2i = mapping.tile
	set_cell(cell, sid, tile)


func get_terrain_at(cache: Display.CellCache, cell: Vector2i) -> int:
	if cell not in cache.cells:
		return -1
	return cache.cells[cell].terrain


func follow_path(cell: Vector2i, path: Array) -> Vector2i:
	for neighbor: TileSet.CellNeighbor in path:
		cell = get_neighbor_cell(cell, neighbor)
	return cell


func reposition() -> void:
	position = offset * Vector2(_tileset_watcher.tile_size)
