class_name Display
extends Node


const TODO = null


var tile_set: TileSet
var grid: Grid
func _init(tile_set: TileSet) -> void:
	print('initializing Display...')
	self.tile_set = tile_set
	grid = tileset_grid(tile_set)
	tile_set.changed.connect(_changed_tile_set)
	
	for layer_config in GRIDS[grid]:
		print('layer_config: %s' % layer_config)
		add_child(DisplayLayer.new(tile_set, layer_config))


## You should replace yourself now
func _changed_tile_set():
	if tileset_grid(tile_set) != grid:
		print('replacing self')
		self.get_parent().add_child(new(tile_set))
		queue_free()


## Returns what kind of grid a TileSet is.
## Defaults to SQUARE.
static func tileset_grid(tile_set: TileSet) -> Grid:
	var hori: bool = tile_set.tile_offset_axis == TileSet.TileOffsetAxis.TILE_OFFSET_AXIS_HORIZONTAL
	match tile_set.tile_shape:
		TileSet.TileShape.TILE_SHAPE_SQUARE:
			return Grid.SQUARE
		TileSet.TileShape.TILE_SHAPE_ISOMETRIC:
			return Grid.ISO
		TileSet.TileShape.TILE_SHAPE_HALF_OFFSET_SQUARE:
			return Grid.HALF_OFF_HORI if hori else Grid.HALF_OFF_VERT
		TileSet.TileShape.TILE_SHAPE_HEXAGON:
			return Grid.HEX_HORI if hori else Grid.HEX_VERT
		_:
			return Grid.SQUARE


enum Grid {
	SQUARE,
	ISO,
	HALF_OFF_HORI,
	HALF_OFF_VERT,
	HEX_HORI,
	HEX_VERT,
}


## How to deal with every available Grid.
const GRIDS: Dictionary = {
	Grid.SQUARE: [
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
	Grid.ISO: [
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
	Grid.HALF_OFF_HORI: [
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
	Grid.HALF_OFF_VERT: [
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
	Grid.HEX_HORI: [
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
	Grid.HEX_VERT: [
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
