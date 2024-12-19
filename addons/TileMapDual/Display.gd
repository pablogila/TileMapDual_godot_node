## Manages up to 2 DisplayLayer children.
class_name Display
extends Node


const TODO = null


var grid: GridShape
var _tileset_watcher: TileSetWatcher
## Creates a new Display that updates when the TileSet updates.
func _init(tileset_watcher: TileSetWatcher) -> void:
	print('initializing Display...')
	_tileset_watcher = tileset_watcher
	tileset_watcher.tileset_created.connect(_tileset_created)
	tileset_watcher.tileset_deleted.connect(_tileset_deleted)
	tileset_watcher.tileset_reshaped.connect(_tileset_reshaped)
	
func _tileset_created():
	for layer_config in GRIDS[_tileset_watcher.grid_shape]:
		print('layer_config: %s' % layer_config)
		add_child(DisplayLayer.new(_tileset_watcher, layer_config))

func _tileset_deleted():
	for child in get_children(true):
		child.queue_free()

func _tileset_reshaped():
	_tileset_created()
	_tileset_deleted()


## Returns what kind of grid a TileSet is.
## Defaults to SQUARE.
static func tileset_gridshape(tile_set: TileSet) -> GridShape:
	var hori: bool = tile_set.tile_offset_axis == TileSet.TILE_OFFSET_AXIS_HORIZONTAL
	match tile_set.tile_shape:
		TileSet.TileShape.TILE_SHAPE_SQUARE:
			return GridShape.SQUARE
		TileSet.TileShape.TILE_SHAPE_ISOMETRIC:
			return GridShape.ISO
		TileSet.TileShape.TILE_SHAPE_HALF_OFFSET_SQUARE:
			return GridShape.HALF_OFF_HORI if hori else GridShape.HALF_OFF_VERT
		TileSet.TileShape.TILE_SHAPE_HEXAGON:
			return GridShape.HEX_HORI if hori else GridShape.HEX_VERT
		_:
			return GridShape.SQUARE


## Every meningfully different TileSet.tile_shape * TileSet.tile_offset_axis combination.
enum GridShape {
	SQUARE,
	ISO,
	HALF_OFF_HORI,
	HALF_OFF_VERT,
	HEX_HORI,
	HEX_VERT,
}


## How to deal with every available GridShape.
const GRIDS: Dictionary = {
	GridShape.SQUARE: [
		{ # []
			'offset': Vector2(-0.5, -0.5),
			'dual_to_display': [
				[],
				[TileSet.CELL_NEIGHBOR_RIGHT_SIDE],
				[TileSet.CELL_NEIGHBOR_BOTTOM_RIGHT_CORNER],
				[TileSet.CELL_NEIGHBOR_BOTTOM_SIDE],
			],
			'display_to_dual': [
				[],
				[TileSet.CELL_NEIGHBOR_LEFT_SIDE],
				[TileSet.CELL_NEIGHBOR_TOP_LEFT_CORNER],
				[TileSet.CELL_NEIGHBOR_TOP_SIDE],
			],
		}
	],
	GridShape.ISO: [
		{ # <>
			'offset': Vector2(0, -0.5),
			'dual_to_display': [
				[], # TOP
				[TileSet.CELL_NEIGHBOR_BOTTOM_RIGHT_SIDE], # RIGHT
				[TileSet.CELL_NEIGHBOR_BOTTOM_CORNER], # BOTTOM
				[TileSet.CELL_NEIGHBOR_BOTTOM_LEFT_SIDE], # LEFT
			],
			'display_to_dual': [
				[TileSet.CELL_NEIGHBOR_TOP_CORNER], # TOP
				[TileSet.CELL_NEIGHBOR_TOP_RIGHT_SIDE], # RIGHT
				[], # BOTTOM
				[TileSet.CELL_NEIGHBOR_TOP_LEFT_SIDE], # LEFT
			],
		}
	],
	GridShape.HALF_OFF_HORI: [
		{ # v
			'offset': TODO,
			'dual_to_display': [
				TODO,
			],
			'display_to_dual': [
				TODO,
			],
		},
		{ # ^
			'offset': TODO,
			'dual_to_display': [
				TODO,
			],
			'display_to_dual': [
				TODO,
			],
		},
	],
	GridShape.HALF_OFF_VERT: [
		{ # >
			'offset': TODO,
			'dual_to_display': [
				TODO,
			],
			'display_to_dual': [
				TODO,
			],
		},
		{ # <
			'offset': TODO,
			'dual_to_display': [
				TODO,
			],
			'display_to_dual': [
				TODO,
			],
		},
	],
	GridShape.HEX_HORI: [
		{
			'offset': TODO,
			'dual_to_display': [
				TODO,
			],
			'display_to_dual': [
				TODO,
			],
		}, {
			'offset': TODO,
			'dual_to_display': [
				TODO,
			],
			'display_to_dual': [
				TODO,
			],
		},
	],
	GridShape.HEX_VERT: [
		{
			'offset': Vector2(-0.25 / sqrt(3), -0.25),
			'dual_to_display': [
				TODO,
			],
			'display_to_dual': [
				TODO,
			],
		}, {
			'offset': Vector2(-0.25 / sqrt(3), -0.75),
			'dual_to_display': [
				TODO,
			],
			'display_to_dual': [
				TODO,
			],
		},
	],
}
