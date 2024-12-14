class_name TerrainDual
extends Resource


@export var layout = []


enum Layout {
	SQUARE,
	TRIANGLE_VERTICAL,
	TRIANGLE_HORIZONTAL,
}


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


const TOPOLOGY_LAYOUTS = {
	DisplayLayer.Topology.SQUARE: Layout.SQUARE,
	DisplayLayer.Topology.ISO: Layout.SQUARE,
	DisplayLayer.Topology.HALF_OFF_HORI: Layout.TRIANGLE_HORIZONTAL,
	DisplayLayer.Topology.HALF_OFF_VERT: Layout.TRIANGLE_VERTICAL,
	DisplayLayer.Topology.HEX_HORI: Layout.TRIANGLE_HORIZONTAL,
	DisplayLayer.Topology.HEX_VERT: Layout.TRIANGLE_VERTICAL,
}

## Would you like to automatically create tiles in the atlas?
static func create_tiles(tile_set: TileSet, atlas: TileSetAtlasSource) -> void:
	atlas.texture_region_size = atlas.texture.get_size() / 4
	
	var terrain_set = tile_set.get_terrain_sets_count()
	tile_set.add_terrain_set()
	tile_set.add_terrain(terrain_set)
	tile_set.set_terrain_name(terrain_set, 0, "Background")
	tile_set.add_terrain(terrain_set)
	tile_set.set_terrain_name(terrain_set, 1, "Foreground")
	
	for y in 4:
		for x in 4:
			var tile := Vector2i(x, y)
			if not atlas.has_tile(tile):
				atlas.create_tile(tile)
			var data = atlas.get_tile_data(tile, 0)
			data.terrain_set = terrain_set
	
	#data.terrain = 
	#data.set_terrain_peering_bit()
