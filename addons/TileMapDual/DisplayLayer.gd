class_name DisplayLayer
extends TileMapLayer


var dual_to_display: Array
var display_to_dual: Array
var offset: Vector2


func _init(tile_set: TileSet, fields: Dictionary) -> void:
	print('initializing Layer...')
	self.tile_set = tile_set
	tile_set.changed.connect(_changed_tile_set)
	offset = fields.offset
	dual_to_display = fields.dual_to_display
	display_to_dual = fields.display_to_dual


func _changed_tile_set() -> void:
	print('layer changed')
	position = offset * Vector2(tile_set.tile_size)
