@tool
class_name Grids

# TODO
const TODO = null


enum GridShape {
	SQUARE,
	ISO,
	HALF_OFF_HORI,
	HALF_OFF_VERT,
	HEX_HORI,
	HEX_VERT,
}


static func grid_shape(tile_set: TileSet) -> GridShape:
	var hori: bool = tile_set.tile_offset_axis == TileSet.TileOffsetAxis.TILE_OFFSET_AXIS_HORIZONTAL
	match tile_set.tile_shape:
		TileSet.TileShape.TILE_SHAPE_SQUARE:
			return Grids.GridShape.SQUARE
		TileSet.TileShape.TILE_SHAPE_ISOMETRIC:
			return Grids.GridShape.ISO
		TileSet.TileShape.TILE_SHAPE_HALF_OFFSET_SQUARE:
			return Grids.GridShape.HALF_OFF_HORI if hori else Grids.GridShape.HALF_OFF_VERT
		TileSet.TileShape.TILE_SHAPE_HEXAGON:
			return Grids.GridShape.HEX_HORI if hori else Grids.GridShape.HEX_VERT
		_:
			return Grids.GridShape.SQUARE


## Dict to assign the Atlas coordinates from the
## summation over all sketched NEIGHBOURS.
const TEMPLATES: Dictionary = {
	'square': [
		[
			Vector2i(0, 3),
			Vector2i(1, 3),
			Vector2i(0, 0),
			Vector2i(3, 0),
			Vector2i(3, 3),
			Vector2i(0, 1),
			Vector2i(3, 2),
			Vector2i(2, 0),
			Vector2i(0, 2),
			Vector2i(1, 0),
			Vector2i(2, 3),
			Vector2i(1, 1),
			Vector2i(1, 2),
			Vector2i(2, 2),
			Vector2i(3, 1),
			Vector2i(2, 1),
		],
	],
	'triangle_vertical': [
		[ # >
			Vector2i(0, 0),
			Vector2i(0, 2),
			Vector2i(1, 1),
			Vector2i(3, 3),
			Vector2i(1, 3),
			Vector2i(3, 1),
			Vector2i(2, 2),
			Vector2i(2, 0),
		], [ # <
			Vector2i(1, 0),
			Vector2i(0, 1),
			Vector2i(1, 2),
			Vector2i(2, 3),
			Vector2i(0, 3),
			Vector2i(3, 2),
			Vector2i(2, 1),
			Vector2i(3, 0),
		],
	],
	'triangle_horizontal':  [
		[ # v
			Vector2i(0, 0),
			Vector2i(2, 0),
			Vector2i(1, 1),
			Vector2i(3, 3),
			Vector2i(3, 1),
			Vector2i(1, 3),
			Vector2i(2, 2),
			Vector2i(0, 2),
		], [# ^
			Vector2i(0, 1),
			Vector2i(1, 0),
			Vector2i(2, 1),
			Vector2i(3, 2),
			Vector2i(3, 0),
			Vector2i(2, 3),
			Vector2i(1, 2),
			Vector2i(0, 3),
		],
	],
}


## How to deal with every available GridShape.
const SHAPE_DATA = [
	{ # GridShape.SQUARE
		'template': TEMPLATES.square,
		'dual_to_display': [[
			TileSet.CELL_NEIGHBOR_RIGHT_SIDE,
			TileSet.CELL_NEIGHBOR_BOTTOM_RIGHT_CORNER,
			TileSet.CELL_NEIGHBOR_BOTTOM_SIDE,
		]],
		'display_to_dual': [[
			TileSet.CELL_NEIGHBOR_LEFT_SIDE,
			TileSet.CELL_NEIGHBOR_TOP_LEFT_CORNER,
			TileSet.CELL_NEIGHBOR_TOP_SIDE,
		]],
	},
	{ # GridShape.ISO
		'template': TEMPLATES.square,
		'offset': [Vector2(0, -0.5)],
		'dual_to_display': [[
			TileSet.CELL_NEIGHBOR_BOTTOM_RIGHT_SIDE,
			TileSet.CELL_NEIGHBOR_BOTTOM_CORNER,
			TileSet.CELL_NEIGHBOR_BOTTOM_LEFT_SIDE,
		]],
		'display_to_dual': [[
			TileSet.CELL_NEIGHBOR_TOP_LEFT_SIDE,
			TileSet.CELL_NEIGHBOR_TOP_CORNER,
			TileSet.CELL_NEIGHBOR_TOP_RIGHT_SIDE,
		]],
	},
	{ # GridShape.HALF_OFF_HORI
		'template': TEMPLATES.triangle_horizontal,
		'offset': TODO,
		'dual_to_display': [
			[TODO],
			[TODO],
		],
		'display_to_dual': [
			[TODO],
			[TODO],
		],
	},
	{ # GridShape.HALF_OFF_VERT
		'template': TEMPLATES.triangle_vertical,
		'offset': TODO,
		'dual_to_display': [
			[TODO],
			[TODO],
		],
		'display_to_dual': [
			[TODO],
			[TODO],
		],
	},
	{ # GridShape.HEX_HORI
		'template': TEMPLATES.triangle_horizontal,
		'offset': [
			TODO, #Vector2(-0.25 / sqrt(3), -0.25),
			TODO, #Vector2(-0.25 / sqrt(3), -0.75),
		],
		'dual_to_display': [
			[TODO],
			[TODO],
		],
		'display_to_dual': [
			[TODO],
			[TODO],
		],
	},
	{ # GridShape.HEX_VERT
		'template': TEMPLATES.triangle_vertical,
		'offset': [
			Vector2(-0.25 / sqrt(3), -0.25),
			Vector2(-0.25 / sqrt(3), -0.75),
		],
		'dual_to_display': [
			[TODO],
			[TODO],
		],
		'display_to_dual': [
			[TODO],
			[TODO],
		],
	},
]
