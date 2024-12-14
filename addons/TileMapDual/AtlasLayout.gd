class_name AtlasLayout
extends Resource


@export var layout = []


enum Layout {
	SQUARE,
	TRIANGLE_VERTICAL,
	TRIANGLE_HORIZONTAL,
}


# TODO: compute the atlas layout based on the terrain configuration.
#func compute_layout(atlas: TileSetAtlasSource) -> Array:


const LAYOUTS: Array[Array] = [
	[ # Layout.SQUARE
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
	[ # Layout.TRIANGLE_VERTICAL
		# >
		Vector2i(0, 0),
		Vector2i(0, 2),
		Vector2i(1, 1),
		Vector2i(3, 3),
		Vector2i(1, 3),
		Vector2i(3, 1),
		Vector2i(2, 2),
		Vector2i(2, 0),
		# <
		Vector2i(1, 0),
		Vector2i(0, 1),
		Vector2i(1, 2),
		Vector2i(2, 3),
		Vector2i(0, 3),
		Vector2i(3, 2),
		Vector2i(2, 1),
		Vector2i(3, 0),
	],
	[ # Layout.TRIANGLE_HORIZONTAL
		# v
		Vector2i(0, 0),
		Vector2i(2, 0),
		Vector2i(1, 1),
		Vector2i(3, 3),
		Vector2i(3, 1),
		Vector2i(1, 3),
		Vector2i(2, 2),
		Vector2i(0, 2),
		# ^
		Vector2i(0, 1),
		Vector2i(1, 0),
		Vector2i(2, 1),
		Vector2i(3, 2),
		Vector2i(3, 0),
		Vector2i(2, 3),
		Vector2i(1, 2),
		Vector2i(0, 3),
	],
]
