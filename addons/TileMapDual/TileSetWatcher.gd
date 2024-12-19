class_name TileSetWatcher
extends Resource

var tile_size: Vector2i
var grid_shape: Display.GridShape
func _init(tile_set: TileSet) -> void:
	tileset_deleted.connect(_tileset_deleted)
	tileset_created.connect(_tileset_created)
	tileset_resized.connect(_tileset_resized)
	tileset_reshaped.connect(_tileset_reshaped)
	atlas_added.connect(_atlas_added)
	terrains_changed.connect(_terrains_changed)
	update(tile_set)


signal tileset_deleted
func _tileset_deleted():
	print('SIGNAL EMITTED: tileset_deleted(%s)' % {})

signal tileset_created
func _tileset_created():
	print('SIGNAL EMITTED: tileset_created(%s)' % {})

signal tileset_resized
func _tileset_resized():
	print('SIGNAL EMITTED: tileset_resized(%s)' % {})

signal tileset_reshaped
func _tileset_reshaped():
	print('SIGNAL EMITTED: tileset_reshaped(%s)' % {})

signal atlas_added(source_id: int, atlas: TileSetAtlasSource)
func _atlas_added(source_id: int, atlas: TileSetAtlasSource):
	print('SIGNAL EMITTED: atlas_added(%s)' % {'source_id': source_id, 'atlas': atlas})

signal terrains_changed
func _terrains_changed():
	print('SIGNAL EMITTED: terrains_changed(%s)' % {})


var tile_set: TileSet
func update(tile_set: TileSet) -> void:
	# Check if tile_set has been added, replaced, or deleted
	if tile_set == self.tile_set:
		return
	if self.tile_set != null:
		self.tile_set.changed.disconnect(_update_tileset)
		tileset_deleted.emit()
		#_update_full_tilemap()
	self.tile_set = tile_set
	if self.tile_set != null:
		self.tile_set.changed.connect(_update_tileset, 1)
		self.tile_set.emit_changed()
		tileset_created.emit()
	emit_changed()


func _update_tileset() -> void:
	var tile_size = tile_set.tile_size
	if self.tile_size != tile_size:
		self.tile_size = tile_size
		tileset_resized.emit()
	var grid_shape = Display.tileset_gridshape(tile_set)
	if self.grid_shape != grid_shape:
		self.grid_shape = grid_shape
		tileset_reshaped.emit()
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
		atlas_added.emit(sid, atlas)
		atlas.changed.connect(func(): terrains_changed.emit())
	terrains_changed.emit()
	_cached_sids = sids
