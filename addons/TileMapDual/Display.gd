class_name Display
extends Node


const TODO = null


enum Grid {
	SQUARE,
	ISO,
	HALF_OFF_HORI,
	HALF_OFF_VERT,
	HEX_HORI,
	HEX_VERT,
}


static func tile_set_grid(tile_set: TileSet) -> Grid:
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
"""

func _init(tile_set: TileSet) -> void:
	for layer_config in GRID_DATA[_grid_shape(tile_set)]:
		add_child(DisplayLayer.new(layer_config))
		TileSetAtlasSource

static func tile_empty(grid_data: Array) -> Vector2i:
	return layers.front().layout.front()


static func tile_full(grid_data: Array) -> Vector2i:
	return layers.front().layout.back()
"""
