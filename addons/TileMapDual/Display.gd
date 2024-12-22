## Manages up to 2 DisplayLayer children.
class_name Display
extends Node


const TODO = null


var terrain: TerrainDual
var _tileset_watcher: TileSetWatcher
## Creates a new Display that updates when the TileSet updates.
func _init(tileset_watcher: TileSetWatcher) -> void:
	print('initializing Display...')
	_tileset_watcher = tileset_watcher
	terrain = TerrainDual.new(tileset_watcher)
	terrain.changed.connect(_tileset_reshaped)
	world_tiles_changed.connect(_world_tiles_changed)

signal world_tiles_changed(changed: Array)
func _world_tiles_changed(changed: Array):
	push_warning('SIGNAL EMITTED: world_tiles_changed(%s)' % {'changed': changed})

func _tileset_created():
	print('GRID SHAPE: %s' % _tileset_watcher.grid_shape)
	var grid: Array = GRIDS[_tileset_watcher.grid_shape]
	for i in grid.size():
		var layer_config: Dictionary = grid[i]
		print('layer_config: %s' % layer_config)
		add_child(DisplayLayer.new(_tileset_watcher, layer_config, terrain.layers[i]))

func _tileset_deleted():
	for child in get_children(true):
		child.queue_free()

func _tileset_reshaped():
	_tileset_deleted()
	_tileset_created()


class CellCache:
	extends Resource

	var cells := {}
	func _init() -> void:
		pass

	## Computes a new CellCache based on the current layer data.
	## Needs the old CellCache in case corrections need to made due to accidents.
	func compute(tile_set: TileSet, layer: TileMapLayer, cache: CellCache) -> void:
		if tile_set == null:
			push_error('Attempted to construct CellCache while tile set was null')
			return
		for cell in layer.get_used_cells():
			# Invalid cells will be treated as empty and ignored
			var sid := layer.get_cell_source_id(cell)
			if not tile_set.has_source(sid):
				continue
			var src = tile_set.get_source(sid)
			var tile := layer.get_cell_atlas_coords(cell)
			if not src.has_tile(tile):
				continue
			var data := layer.get_cell_tile_data(cell)
			if data == null:
				continue
			# Accidental cells should be reset to their previous value
			# They will be treated as unchanged
			if data.terrain == -1 or data.terrain_set != 0:
				if cell not in cache.cells:
					layer.erase_cell(cell)
					continue
				var cached: Dictionary = cache.cells[cell]
				sid = cached.sid
				tile = cached.tile
				layer.set_cell(cell, cached.sid, cached.tile)
			cells[cell] = {'sid': sid, 'tile': tile}

	## Returns the difference between two tile caches
	func diff(other: CellCache) -> Array[Vector2i]:
		var out: Array[Vector2i] = []
		for key in self.cells:
			if key not in other.cells:
				out.push_back(key)
		for key in other.cells:
			if key not in self.cells:
				out.push_back(key)
		return out


# TODO: write the map diff algorithm and connect it to the display dual grid neighbor thing
## {Vector2i: {'sid': int, 'tile': Vector2i}}
var _cached_cells := CellCache.new()
## Updates the display based on the cells found in the TileMapLayer.
func update(layer: TileMapLayer):
	if _tileset_watcher.tile_set == null:
		return
	var current := CellCache.new()
	current.compute(_tileset_watcher.tile_set, layer, _cached_cells)
	var updated := current.diff(_cached_cells)
	_cached_cells = current
	if not updated.is_empty():
		world_tiles_changed.emit(updated)


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
