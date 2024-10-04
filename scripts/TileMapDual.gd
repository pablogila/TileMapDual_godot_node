@tool
class_name TileMapDual
extends TileMapLayer

## TileMapLayer in the World grid, where the tiles are sketched.
## An offset of (-0.5,-0.5) tiles will be applied
## with respect to the World grid.
## Sketch here with the corresponding fully-filled tile
## from the standard tileset, indicated as sketch_atlas_coord.
var world_tilemap: TileMapLayer = null
@export var debug = false

func _ready() -> void:
	self.connect('changed', self._on_changed)

func get_cells_for(cell: Vector2i, map = world_tilemap) -> Array:
	return [cell,
	map.get_neighbor_cell(cell, TileSet.CellNeighbor.CELL_NEIGHBOR_RIGHT_SIDE),
	map.get_neighbor_cell(cell, TileSet.CellNeighbor.CELL_NEIGHBOR_BOTTOM_SIDE),
	map.get_neighbor_cell(cell, TileSet.CellNeighbor.CELL_NEIGHBOR_BOTTOM_RIGHT_CORNER)]


#@onready var used_cells : Array = get_used_cells()
@onready var map_size = tile_map_data.size()
var used_cache = {}

func _process(delta: float) -> void:
	var size = tile_map_data.size()
	if map_size != size:
		# Slow but very efficient
		if size < (map_size - 50):
			if debug:
				print("Remove all cells")
			world_tilemap.clear()
			used_cache.clear()
			var add_cells = {}
			for cell in get_used_cells():
				used_cache[cell] = true
				for c in get_cells_for(cell):
					add_cells[c] = true
			world_tilemap.set_cells_terrain_connect(add_cells.keys(), 0, 0)
		elif size < map_size:
			if debug:
				print("Remove cell")
			remove_tiles()
		else:
			add_tiles()
		map_size = size
		

# For removing a few tiles at a time quickly
# Remove a cell and replace the ones around for autotiling
func remove_tiles() -> bool:
	var removed = false
	for cell in used_cache:
		if !get_cell_tile_data(cell):
			removed = true
			used_cache.erase(cell)
			var tile_data = world_tilemap.get_cell_tile_data(cell)
			if tile_data:
				var reset_cells = []
				var start_cell = world_tilemap.get_neighbor_cell(cell, TileSet.CELL_NEIGHBOR_TOP_LEFT_CORNER)
				# Reset cells within a block of 4x4
				for i in 4:
					var current_cell = start_cell
					for k in 4:
						if world_tilemap.get_cell_tile_data(current_cell):
							world_tilemap.erase_cell(current_cell)
							reset_cells.push_back(current_cell)
						current_cell = world_tilemap.get_neighbor_cell(current_cell, TileSet.CELL_NEIGHBOR_BOTTOM_SIDE)
					start_cell = world_tilemap.get_neighbor_cell(start_cell, TileSet.CELL_NEIGHBOR_RIGHT_SIDE)
				for remove_cell in get_cells_for(cell):
					reset_cells.erase(remove_cell)
					world_tilemap.erase_cell(remove_cell)
				world_tilemap.set_cells_terrain_connect(reset_cells, tile_data.terrain_set, tile_data.terrain)
	return removed

func add_tiles():
	# Add the Overlapping tiles for the cells added
	for cell in get_used_cells():
		if !used_cache.has(cell):
			used_cache[cell] = true
			if debug:
				print("Added cell ", cell)
			var tile_data = get_cell_tile_data(cell)
			world_tilemap.set_cells_terrain_connect(get_cells_for(cell), tile_data.terrain_set, tile_data.terrain)
	
func _on_changed() -> void:
	# Create offset tileset once TileSet has been created
	if self.tile_set and !world_tilemap:
		world_tilemap = TileMapLayer.new()
		world_tilemap.position = (self.tile_set.tile_size * Vector2i(-1, -1)) / Vector2i(2, 2)
		world_tilemap.tile_set = self.tile_set
		add_child(world_tilemap)
		# Make this map invisible without disabling it
		self.material = CanvasItemMaterial.new()
		self.material.light_mode = CanvasItemMaterial.LightMode.LIGHT_MODE_LIGHT_ONLY
