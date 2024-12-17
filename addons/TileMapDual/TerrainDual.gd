class_name TerrainDual
extends Resource

# Functions are ordered top to bottom in the transformation pipeline

static func tile_set_neighborhood(tile_set: TileSet) -> Neighborhood:
	return GRID_NEIGHBORHOODS[Display.tileset_grid(tile_set)]


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


var terrain: Dictionary
var filter: Array
func _init(tile_set: TileSet, filter: Array) -> void:
	read_tile_set(tile_set, filter)


func read_tile_set(tile_set: TileSet, filter: Array) -> void:
	self.terrain = {}
	self.filter = filter
	for i in tile_set.get_source_count():
		var sid := tile_set.get_source_id(i)
		var src := tile_set.get_source(i)
		if src is not TileSetAtlasSource:
			continue
		read_atlas(src, sid)


func read_atlas(atlas: TileSetAtlasSource, sid: int) -> void:
	# Read every tile in the atlas
	var size = atlas.get_atlas_grid_size()
	for y in size.y:
		for x in size.x:
			var tile := Vector2i(x, y)
			# Take only existing tiles
			if not atlas.has_tile(tile):
				continue
			var data := atlas.get_tile_data(tile, 0)
			var condition := filter.map(data.get_terrain_peering_bit)
			# Skip tiles with no peering bits in this filter
			# They might be used for a different layer,
			# or may have no peering bits at all, which will just be ignored by all layers
			if condition.all(func(neighbor): neighbor == -1):
				continue
			var mapping := { 'sid': sid, 'tile': tile }
			if condition in terrain:
				var prev_mapping = terrain[condition]
				push_warning(
					"2 different tiles in this TileSet have the same Terrain configuration:\n" +
					"1st: %s\n" % [prev_mapping] +
					"2nd: %s" % [mapping]
				)
			terrain[condition] = mapping


## Would you like to automatically create tiles in the atlas?
static func write_default_preset(tile_set: TileSet, atlas: TileSetAtlasSource) -> void:
	print('writing default')
	var neighborhood := tile_set_neighborhood(tile_set)
	var terrain_offset := create_false_terrain_set(
		tile_set,
		atlas.texture.resource_path.get_file()
	)
	write_preset(
		atlas,
		NEIGHBORHOODS[neighborhood],
		neighborhood_preset(neighborhood),
		terrain_offset + 0,
		terrain_offset + 1,
	)


static func create_false_terrain_set(tile_set: TileSet, terrain_name: String) -> int:
	if tile_set.get_terrain_sets_count() == 0:
		tile_set.add_terrain_set()
		tile_set.set_terrain_set_mode(0, TileSet.TERRAIN_MODE_MATCH_CORNERS)
	var terrain_offset = tile_set.get_terrains_count(0)
	tile_set.add_terrain(0)
	tile_set.set_terrain_name(0, terrain_offset + 0, "BG - %s" % terrain_name)
	tile_set.add_terrain(0)
	tile_set.set_terrain_name(0, terrain_offset + 1, "FG - %s" % terrain_name)
	return terrain_offset


static func write_preset(
	atlas: TileSetAtlasSource,
	neighborhood: Array,
	preset: Dictionary,
	terrain_background: int,
	terrain_foreground: int,
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
			data.terrain_set = 0
			for neighbor in filter:
				data.set_terrain_peering_bit(
					neighbor,
					[terrain_background, terrain_foreground][i & 1]
				)
				i >>= 1
	# Set terrains
	var first_sequence: Array = sequences.front()
	var tile_bg: Vector2i = first_sequence.front()
	var tile_fg: Vector2i = first_sequence.back()
	atlas.get_tile_data(tile_bg, 0).terrain = terrain_background
	atlas.get_tile_data(tile_fg, 0).terrain = terrain_foreground


static func clear_and_resize_atlas(atlas: TileSetAtlasSource, size: Vector2i):
	# Clear all tiles
	atlas.texture_region_size = atlas.texture.get_size() + Vector2.ONE
	atlas.clear_tiles_outside_texture()
	# Resize the tiles
	atlas.texture_region_size = atlas.texture.get_size() / Vector2(size)
