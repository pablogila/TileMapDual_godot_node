class_name Display
extends Node


const TODO = null


enum Topology {
	SQUARE,
	ISO,
	HALF_OFF_HORI,
	HALF_OFF_VERT,
	HEX_HORI,
	HEX_VERT,
}


static func get_topology(tile_set: TileSet) -> Topology:
	var hori: bool = tile_set.tile_offset_axis == TileSet.TileOffsetAxis.TILE_OFFSET_AXIS_HORIZONTAL
	match tile_set.tile_shape:
		TileSet.TileShape.TILE_SHAPE_SQUARE:
			return Topology.SQUARE
		TileSet.TileShape.TILE_SHAPE_ISOMETRIC:
			return Topology.ISO
		TileSet.TileShape.TILE_SHAPE_HALF_OFFSET_SQUARE:
			return Topology.HALF_OFF_HORI if hori else Topology.HALF_OFF_VERT
		TileSet.TileShape.TILE_SHAPE_HEXAGON:
			return Topology.HEX_HORI if hori else Topology.HEX_VERT
		_:
			return Topology.SQUARE

"""


## How to deal with every available Topology.
const TOPOLOGIES: Array[Array] = [
	[{ # Topology.SQUARE
		'layout': AtlasLayout.LAYOUTS.square,
		'offset': Vector2(-0.5, -0.5),
		'dual_to_display': [
			TileSet.CELL_NEIGHBOR_RIGHT_SIDE,
			TileSet.CELL_NEIGHBOR_BOTTOM_RIGHT_CORNER,
			TileSet.CELL_NEIGHBOR_BOTTOM_SIDE,
		],
		'display_to_dual': [
			TileSet.CELL_NEIGHBOR_LEFT_SIDE,
			TileSet.CELL_NEIGHBOR_TOP_LEFT_CORNER,
			TileSet.CELL_NEIGHBOR_TOP_SIDE,
		],
	}],
	[{ # Topology.ISO
		'layout': AtlasLayout.LAYOUTS.square,
		'offset': Vector2(0, -0.5),
		'dual_to_display': [
			TileSet.CELL_NEIGHBOR_BOTTOM_RIGHT_SIDE,
			TileSet.CELL_NEIGHBOR_BOTTOM_CORNER,
			TileSet.CELL_NEIGHBOR_BOTTOM_LEFT_SIDE,
		],
		'display_to_dual': [
			TileSet.CELL_NEIGHBOR_TOP_LEFT_SIDE,
			TileSet.CELL_NEIGHBOR_TOP_CORNER,
			TileSet.CELL_NEIGHBOR_TOP_RIGHT_SIDE,
		],
	}],
	[ # Topology.HALF_OFF_HORI
		{
			'layout': AtlasLayout.LAYOUTS.triangle_horizontal_down,
			'offset': TODO,
			'dual_to_display': [
				TODO,
			],
			'display_to_dual': [
				TODO,
			],
		}, {
			'layout': AtlasLayout.LAYOUTS.triangle_horizontal_up,
			'offset': TODO,
			'dual_to_display': [
				TODO,
			],
			'display_to_dual': [
				TODO,
			],
		},
	],
	[ # Topology.HALF_OFF_VERT
		{
			'layout': AtlasLayout.LAYOUTS.triangle_vertical_right,
			'offset': TODO,
			'dual_to_display': [
				TODO,
			],
			'display_to_dual': [
				TODO,
			],
		}, {
			'layout': AtlasLayout.LAYOUTS.triangle_vertical_left,
			'offset': TODO,
			'dual_to_display': [
				TODO,
			],
			'display_to_dual': [
				TODO,
			],
		},
	],
	[ # Topology.HEX_HORI
		{
			'layout': AtlasLayout.LAYOUTS.triangle_horizontal_down,
			'offset': TODO,
			'dual_to_display': [
				TODO,
			],
			'display_to_dual': [
				TODO,
			],
		}, {
			'layout': AtlasLayout.LAYOUTS.triangle_horizontal_up,
			'offset': TODO,
			'dual_to_display': [
				TODO,
			],
			'display_to_dual': [
				TODO,
			],
		},
	],
	[ # Topology.HEX_VERT
		{
			'layout': AtlasLayout.LAYOUTS.triangle_vertical_right,
			'offset': Vector2(-0.25 / sqrt(3), -0.25),
			'dual_to_display': [
				TODO,
			],
			'display_to_dual': [
				TODO,
			],
		}, {
			'layout': AtlasLayout.LAYOUTS.triangle_vertical_left,
			'offset': Vector2(-0.25 / sqrt(3), -0.75),
			'dual_to_display': [
				TODO,
			],
			'display_to_dual': [
				TODO,
			],
		},
	],
]

func _init(tile_set: TileSet) -> void:
	for layer_config in GRID_DATA[_grid_shape(tile_set)]:
		add_child(DisplayLayer.new(layer_config))
		TileSetAtlasSource

static func tile_empty(grid_data: Array) -> Vector2i:
	return layers.front().layout.front()


static func tile_full(grid_data: Array) -> Vector2i:
	return layers.front().layout.back()
"""
