class_name DisplayLayer
extends TileMapLayer


var dual_to_display: Array
var display_to_dual: Array
var offset: Vector2
var _tileset_watcher: TileSetWatcher
func _init(tileset_watcher: TileSetWatcher, fields: Dictionary) -> void:
	print('initializing Layer...')
	_tileset_watcher = tileset_watcher
	tileset_watcher.tileset_resized.connect(resize)
	tileset_watcher.terrains_changed.connect(update_tiles_full)
	offset = fields.offset
	dual_to_display = fields.dual_to_display
	display_to_dual = fields.display_to_dual


func update_tiles_full() -> void:
	print('Update tiles full')


func update_tiles(tiles: Set) -> void:
	print('Update tiles: %s' % tiles)


func resize() -> void:
	position = offset * Vector2(_tileset_watcher.tile_size)
