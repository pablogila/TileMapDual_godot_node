class_name TileSetWatcher
extends Resource

var tile_set: TileSet
func _init(tile_set: TileSet) -> void:
	update(tile_set)


signal tileset_deleted
func _tileset_deleted():
	print('SIGNAL EMITTED: tileset_deleted(%s)' % {})

signal tileset_added(tile_set: TileSet)
func _tileset_added(tile_set: TileSet):
	print('SIGNAL EMITTED: tileset_added(%s)' % {'tile_set': tile_set})

signal tileset_resized(tile_set: TileSet)
func _tileset_resized(tile_set: TileSet):
	print('SIGNAL EMITTED: tileset_resized(%s)' % {'tile_set': tile_set})

signal tileset_reshaped(tile_set: TileSet, new_grid: Display.GridShape)
func _tileset_reshaped(tile_set: TileSet, new_grid: Display.GridShape):
	print('SIGNAL EMITTED: tileset_reshaped(%s)' % {'tile_set': tile_set, 'new_grid': new_grid})

signal atlas_added(tile_set: TileSet, source_id: int, atlas: TileSetAtlasSource)
func _atlas_added(tile_set: TileSet, source_id: int, atlas: TileSetAtlasSource):
	print('SIGNAL EMITTED: atlas_added(%s)' % {'tile_set': tile_set, 'source_id': source_id, 'atlas': atlas})

signal terrains_changed(tile_set: TileSet)
func _terrains_changed(tile_set: TileSet):
	print('SIGNAL EMITTED: terrains_changed(%s)' % {'tile_set': tile_set})


func update(tile_set: TileSet) -> void:
	# Check if tile_set has been added, replaced, or deleted
	if tile_set == self.tile_set:
		return
	emit_changed()
	if self.tile_set != null:
		self.tile_set.changed.disconnect(_update_tileset)
		tileset_deleted.emit()
		#_update_full_tilemap()
	if tile_set != null:
		tile_set.changed.connect(_update_tileset, 1)
		tile_set.emit_changed()
		tileset_added.emit(tile_set)
	self.tile_set = tile_set


var _cached_tile_size: Vector2i
var _cached_grid: Display.GridShape
func _update_tileset() -> void:
	var new_size = tile_set.tile_size
	if _cached_tile_size != new_size:
		tileset_resized.emit(new_size)
		_cached_tile_size = new_size
	var new_gridshape = Display.tileset_gridshape(tile_set)
	if _cached_grid != new_gridshape:
		tileset_reshaped.emit(new_gridshape)
		_cached_grid = new_gridshape
	_update_tileset_atlases()


## Configures all tile set atlases
# TODO: detect automatic tile creation
var _cached_source_count: int = 0
var _cached_sids := Set.new()
func _update_tileset_atlases():
	# Update all tileset sources
	var source_count := tile_set.get_source_count()
	var terrain_set_count := tile_set.get_terrain_sets_count()
	# Only if an asset was added or removed
	if _cached_source_count == source_count:
		return
	_cached_source_count = source_count
	
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
		atlas_added.emit(tile_set, sid, atlas)
		atlas.changed.connect(func(): terrains_changed.emit(tile_set))
	terrains_changed.emit(tile_set)
	_cached_sids = sids
