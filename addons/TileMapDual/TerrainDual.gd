class_name TerrainDual
extends Resource

# Functions are ordered top to bottom in the transformation pipeline

static func tile_set_neighborhood(tile_set: TileSet) -> Neighborhood:
	return GRID_NEIGHBORHOODS[Display.tile_set_grid(tile_set)]


const GRID_NEIGHBORHOODS = {
	Display.Grid.SQUARE: Neighborhood.SQUARE,
	Display.Grid.ISO: Neighborhood.ISOMETRIC,
	Display.Grid.HALF_OFF_HORI: Neighborhood.TRIANGLE_HORIZONTAL,
	Display.Grid.HALF_OFF_VERT: Neighborhood.TRIANGLE_VERTICAL,
	Display.Grid.HEX_HORI: Neighborhood.TRIANGLE_HORIZONTAL,
	Display.Grid.HEX_VERT: Neighborhood.TRIANGLE_VERTICAL,
}


enum Neighborhood {
	SQUARE,
	ISOMETRIC,
	TRIANGLE_HORIZONTAL,
	TRIANGLE_VERTICAL,
}


## Maps a Layout to a display_to_dual neighborhood.
const NEIGHBORHOODS := {
	Neighborhood.SQUARE: [
		[ # []
			TileSet.CELL_NEIGHBOR_TOP_LEFT_CORNER,
			TileSet.CELL_NEIGHBOR_TOP_RIGHT_CORNER,
			TileSet.CELL_NEIGHBOR_BOTTOM_LEFT_CORNER,
			TileSet.CELL_NEIGHBOR_BOTTOM_RIGHT_CORNER,
		]
	],
	Neighborhood.ISOMETRIC: [
		[ # <>
			TileSet.CELL_NEIGHBOR_TOP_CORNER,
			TileSet.CELL_NEIGHBOR_RIGHT_CORNER,
			TileSet.CELL_NEIGHBOR_LEFT_CORNER,
			TileSet.CELL_NEIGHBOR_BOTTOM_CORNER,
		]
	],
	Neighborhood.TRIANGLE_HORIZONTAL: [
		[ # v
			TileSet.CELL_NEIGHBOR_BOTTOM_CORNER,
			TileSet.CELL_NEIGHBOR_TOP_LEFT_CORNER,
			TileSet.CELL_NEIGHBOR_TOP_RIGHT_CORNER,
		],
		[ # ^
			TileSet.CELL_NEIGHBOR_TOP_CORNER,
			TileSet.CELL_NEIGHBOR_BOTTOM_LEFT_CORNER,
			TileSet.CELL_NEIGHBOR_BOTTOM_RIGHT_CORNER,
		],
	],
	Neighborhood.TRIANGLE_VERTICAL: [
		[ # >
			TileSet.CELL_NEIGHBOR_RIGHT_CORNER,
			TileSet.CELL_NEIGHBOR_TOP_LEFT_CORNER,
			TileSet.CELL_NEIGHBOR_BOTTOM_LEFT_CORNER,
		],
		[ # <
			TileSet.CELL_NEIGHBOR_LEFT_CORNER,
			TileSet.CELL_NEIGHBOR_TOP_RIGHT_CORNER,
			TileSet.CELL_NEIGHBOR_BOTTOM_RIGHT_CORNER,
		],
	],
}


const NEIGHBORHOOD_TOPOLOGIES := {
	Neighborhood.SQUARE: Topology.SQUARE,
	Neighborhood.ISOMETRIC: Topology.SQUARE,
	Neighborhood.TRIANGLE_HORIZONTAL: Topology.TRIANGLE,
	Neighborhood.TRIANGLE_VERTICAL: Topology.TRIANGLE,
}


enum Topology {
	SQUARE,
	TRIANGLE,
}


static func flipped_xy(v: Vector2i) -> Vector2i:
	return Vector2i(v.y, v.x)


static func neighborhood_preset(
	neighborhood: Neighborhood,
	name: String = 'Standard'
) -> Dictionary:
	var topology: Topology = NEIGHBORHOOD_TOPOLOGIES[neighborhood]
	var out: Dictionary = PRESETS[topology][name].duplicate(true)
	# All Horizontal neighborhoods are also available as Vertical
	if neighborhood == Neighborhood.TRIANGLE_VERTICAL:
		out.size = flipped_xy(out.size)
		for seq in out.sequences:
			for i in seq.size():
				seq[i] = flipped_xy(seq[i])
	return out


const PRESETS := {
	Topology.SQUARE: {
		'Standard': {
			'size': Vector2i(4, 4),
			'sequences': [
				[ # []
					Vector2i(0, 3),
					Vector2i(3, 3),
					Vector2i(0, 2),
					Vector2i(1, 2),
					Vector2i(0, 0),
					Vector2i(3, 2),
					Vector2i(2, 3),
					Vector2i(3, 1),
					Vector2i(1, 3),
					Vector2i(0, 1),
					Vector2i(1, 0),
					Vector2i(2, 2),
					Vector2i(3, 0),
					Vector2i(2, 0),
					Vector2i(1, 1),
					Vector2i(2, 1),
				],
			],
		},
	},
	Topology.TRIANGLE: {
		'Standard': {
			'size': Vector2i(4, 4),
			'sequences': [
				[ # v
					Vector2i(0, 0),
					Vector2i(2, 0),
					Vector2i(3, 1),
					Vector2i(1, 3),
					Vector2i(1, 1),
					Vector2i(3, 3),
					Vector2i(2, 2),
					Vector2i(0, 2),
				],
				[ # ^
					Vector2i(0, 1),
					Vector2i(2, 1),
					Vector2i(3, 0),
					Vector2i(1, 2),
					Vector2i(1, 0),
					Vector2i(3, 2),
					Vector2i(2, 3),
					Vector2i(0, 3),
				],
			],
		},
	},
}


const NEIGHBORS: Array[TileSet.CellNeighbor] = [
	TileSet.CELL_NEIGHBOR_RIGHT_CORNER,
	TileSet.CELL_NEIGHBOR_BOTTOM_RIGHT_CORNER,
	TileSet.CELL_NEIGHBOR_BOTTOM_CORNER,
	TileSet.CELL_NEIGHBOR_BOTTOM_LEFT_CORNER,
	TileSet.CELL_NEIGHBOR_LEFT_CORNER,
	TileSet.CELL_NEIGHBOR_TOP_LEFT_CORNER,
	TileSet.CELL_NEIGHBOR_TOP_CORNER,
	TileSet.CELL_NEIGHBOR_TOP_RIGHT_CORNER,
]


## The exact type is {[int; 8]: Vector2i}
@export var terrain: Dictionary = {}
func _init(atlas: TileSetAtlasSource) -> void:
	var size = atlas.get_atlas_grid_size()
	for y in size.y:
		for x in size.x:
			var tile := Vector2i(x, y)
			if not atlas.has_tile(tile):
				continue
			var data := atlas.get_tile_data(tile, 0)
			terrain[NEIGHBORS.map(data.get_terrain_peering_bit)] = tile


## Would you like to automatically create tiles in the atlas?
static func write_default_preset(tile_set: TileSet, atlas: TileSetAtlasSource) -> void:
	print('writing default')
	var neighborhood := tile_set_neighborhood(tile_set)
	write_preset(
		atlas,
		NEIGHBORHOODS[neighborhood],
		neighborhood_preset(neighborhood),
		create_terrain_set(tile_set)
	)


static func create_terrain_set(tile_set: TileSet) -> int:
	var terrain_set := tile_set.get_terrain_sets_count()
	tile_set.add_terrain_set()
	tile_set.set_terrain_set_mode(terrain_set, TileSet.TERRAIN_MODE_MATCH_CORNERS)
	tile_set.add_terrain(terrain_set)
	tile_set.set_terrain_name(terrain_set, 0, "Background")
	tile_set.add_terrain(terrain_set)
	tile_set.set_terrain_name(terrain_set, 1, "Foreground")
	return terrain_set


static func write_preset(
	atlas: TileSetAtlasSource,
	neighborhood: Array,
	preset: Dictionary,
	terrain_set: int,
	terrain_background: int = 0,
	terrain_foreground: int = 1,
) -> void:
	print('writing')
	clear_and_resize_atlas(atlas, preset.size)
	# Set peering bits
	var sequences: Array = preset.sequences
	for j in neighborhood.size():
		var filter = neighborhood[j]
		var sequence: Array = sequences[j]
		for i in sequence.size():
			var tile: Vector2i = sequence[i]
			atlas.create_tile(tile)
			var data := atlas.get_tile_data(tile, 0)
			data.terrain_set = terrain_set
			for neighbor in filter:
				data.set_terrain_peering_bit(neighbor, i & 1)
				i >>= 1
	# Set terrains
	var first_sequence: Array = sequences.front()
	var tile_bg: Vector2i = first_sequence.front()
	var tile_fg: Vector2i = first_sequence.back()
	atlas.get_tile_data(tile_bg, 0).terrain = 0
	atlas.get_tile_data(tile_fg, 0).terrain = 1


static func clear_and_resize_atlas(atlas: TileSetAtlasSource, size: Vector2i):
	# Clear all tiles
	atlas.texture_region_size = atlas.texture.get_size() + Vector2.ONE
	atlas.clear_tiles_outside_texture()
	# Resize the tiles
	atlas.texture_region_size = atlas.texture.get_size() / Vector2(size)
