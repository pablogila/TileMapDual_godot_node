class_name DisplayLayer
extends TileMapLayer


var dual_to_display: Array
var display_to_dual: Array
var offset: Vector2
var _tileset_watcher: TileSetWatcher
func _init(
	tileset_watcher: TileSetWatcher,
	fields: Dictionary,
	layer: TerrainDual.TerrainLayer
) -> void:
	print('initializing Layer...')
	_tileset_watcher = tileset_watcher
	tileset_watcher.tileset_resized.connect(resize)
	offset = fields.offset
	dual_to_display = fields.dual_to_display
	display_to_dual = fields.display_to_dual


func update_tiles(cells: Array) -> void:
	print('Update tiles')
	for cell: Vector2i in cells:
		print(cell)


func resize() -> void:
	position = offset * Vector2(_tileset_watcher.tile_size)
