class_name TileSetWatcher
extends Resource

var tile_size: Vector2i
var grid_shape: Display.GridShape
func _init(tile_set: TileSet) -> void:
	tileset_deleted.connect(_tileset_deleted, 1)
	tileset_created.connect(_tileset_created, 1)
	tileset_resized.connect(_tileset_resized, 1)
	tileset_reshaped.connect(_tileset_reshaped, 1)
	atlas_added.connect(_atlas_added, 1)
	terrains_changed.connect(_terrains_changed, 1)
	update(tile_set)


var _flag_tileset_deleted := false
signal tileset_deleted
func _tileset_deleted():
	#print('SIGNAL EMITTED: tileset_deleted(%s)' % {})
	#tileset_reshaped.emit()
	pass

var _flag_tileset_created := false
signal tileset_created
func _tileset_created():
	#print('SIGNAL EMITTED: tileset_created(%s)' % {})
	#tileset_reshaped.emit()
	pass

var _flag_tileset_resized := false
signal tileset_resized
func _tileset_resized():
	#print('SIGNAL EMITTED: tileset_resized(%s)' % {})
	pass

var _flag_tileset_reshaped := false
signal tileset_reshaped
func _tileset_reshaped():
	#print('SIGNAL EMITTED: tileset_reshaped(%s)' % {})
	#terrains_changed.emit()
	pass

var _flag_atlas_added := false
signal atlas_added(source_id: int, atlas: TileSetAtlasSource)
func _atlas_added(source_id: int, atlas: TileSetAtlasSource):
	_flag_atlas_added = true
	#print('SIGNAL EMITTED: atlas_added(%s)' % {'source_id': source_id, 'atlas': atlas})
	#terrains_changed.emit()
	pass

var _flag_terrains_changed := false
signal terrains_changed
func _terrains_changed():
	#print('SIGNAL EMITTED: terrains_changed(%s)' % {})
	pass


func update(tile_set: TileSet) -> void:
	check_tile_set(tile_set)
	check_flags()


## Emit updates if the corresponding flags were set.
## Must only be run once per frame.
func check_flags() -> void:
	if _flag_tileset_changed:
		_update_tileset()
	if _flag_tileset_deleted:
		_flag_tileset_deleted = false
		_flag_tileset_reshaped = true
		tileset_deleted.emit()
	if _flag_tileset_created:
		_flag_tileset_created = false
		_flag_tileset_reshaped = true
		tileset_created.emit()
	if _flag_tileset_resized:
		_flag_tileset_resized = false
		tileset_resized.emit()
	if _flag_tileset_reshaped:
		_flag_tileset_reshaped = false
		_flag_terrains_changed = true
		tileset_reshaped.emit()
	if _flag_atlas_added:
		_flag_atlas_added = false
		_flag_terrains_changed = true
	if _flag_terrains_changed:
		_flag_terrains_changed = false
		terrains_changed.emit()


var tile_set: TileSet
## Check if tile_set has been added, replaced, or deleted.
func check_tile_set(tile_set: TileSet) -> void:
	if tile_set == self.tile_set:
		return
	if self.tile_set != null:
		self.tile_set.changed.disconnect(_set_tileset_changed)
		_cached_source_count = 0
		_cached_sids.clear()
		_flag_tileset_deleted = true
	self.tile_set = tile_set
	if self.tile_set != null:
		self.tile_set.changed.connect(_set_tileset_changed, 1)
		self.tile_set.emit_changed()
		_flag_tileset_created = true
	emit_changed()


var _flag_tileset_changed := false
func _set_tileset_changed() -> void:
	_flag_tileset_changed = true


func _update_tileset() -> void:
	var tile_size = tile_set.tile_size
	if self.tile_size != tile_size:
		self.tile_size = tile_size
		_flag_tileset_resized = true
	var grid_shape = Display.tileset_gridshape(tile_set)
	if self.grid_shape != grid_shape:
		self.grid_shape = grid_shape
		_flag_tileset_reshaped = true
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
		#print('checking')
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
		atlas.changed.connect(func(): _flag_terrains_changed = true, 1)
	#push_error('update atlases')
	_flag_terrains_changed = true
	_cached_sids = sids
