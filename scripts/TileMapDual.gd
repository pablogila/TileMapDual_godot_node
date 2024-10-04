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

func add_tile(coords: Vector2i, tile_data: TileData) -> void:
	world_tilemap.set_cells_terrain_connect(get_cells_for(coords), tile_data.terrain_set, tile_data.terrain)

func get_cells_for(cell: Vector2i, map = world_tilemap) -> Array:
	return [cell,
	map.get_neighbor_cell(cell, TileSet.CellNeighbor.CELL_NEIGHBOR_RIGHT_SIDE),
	map.get_neighbor_cell(cell, TileSet.CellNeighbor.CELL_NEIGHBOR_BOTTOM_SIDE),
	map.get_neighbor_cell(cell, TileSet.CellNeighbor.CELL_NEIGHBOR_BOTTOM_RIGHT_CORNER)]


@onready var used_cells : Array = get_used_cells()
@onready var map_size = tile_map_data.size()

func _process(delta: float) -> void:
	var size = tile_map_data.size()
	# Only process if tile data has changed
	if map_size != size:
		map_size = size
		var current_cells = get_used_cells()
		var removed_cells = []
		for cell in used_cells:
			if !current_cells.has(cell):
				if debug:
					print("Removed cell ", cell)
				removed_cells.push_front(cell)
				used_cells.erase(cell)
				
		if removed_cells.size() > 0:
			if removed_cells.size() == 1:
				# If surrounding tiles are all set, remove 4 tiles at once (Otherwise nothing happens)
				if get_surrounding_cells(removed_cells[0]).all(func(element): return current_cells.has(element)):
					for cell in get_cells_for(removed_cells[0], self):
						if debug:
							print("   Removed cell ", cell)
						used_cells.erase(cell)
						current_cells.erase(cell)
						erase_cell(cell)
			
			# Clear out tiles and re-set them (Otherwise tiles will not rearrange)
			world_tilemap.clear()
			for cell in current_cells:
				var tile_data = get_cell_tile_data(cell)
				add_tile(cell, tile_data)
			# Skip add logic if anything was removed
			return
		
		# Add the Overlapping tiles for the cells added
		for cell in current_cells:
			if !used_cells.has(cell):
				used_cells.append(cell)
				if debug:
					print("Added cell ", cell)
				var tile_data = get_cell_tile_data(cell)
				add_tile(cell, tile_data)
			
	
func _on_changed() -> void:
	# Create offset tileset once TileSet has been created
	if self.tile_set and !world_tilemap:
		world_tilemap = TileMapLayer.new()
		world_tilemap.position = (self.tile_set.tile_size * Vector2i(-1, -1)) / Vector2i(2, 2)
		world_tilemap.tile_set = self.tile_set
		add_child(world_tilemap)
