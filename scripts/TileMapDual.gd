@tool
class_name TileMapDual
extends TileMapLayer

## TileMapLayer in the World grid, where the tiles are sketched.
## An offset of (-0.5,-0.5) tiles will be applied
## with respect to the World grid.
## Sketch here with the corresponding fully-filled tile
## from the standard tileset, indicated as sketch_atlas_coord.
var world_tilemap: TileMapLayer = null
@export var debug: bool = false
@onready var map_size = tile_map_data.size()
var used_cache = {}

## We will use a bit-wise logic, so that
## a summation over all sketched neighbours
## provides a unique key, that will be assigned
## to the corresponding tile from the Atlas
## through the NEIGHBOURS_TO_ATLAS dictionary.
enum location {
	TOP_LEFT  = 1,
	LOW_LEFT  = 2,
	TOP_RIGHT  = 4,
	LOW_RIGHT  = 8,
}

enum direction {
	TOP,
	LEFT,
	BOTTOM,
	RIGHT,
	BOTTOM_RIGHT,
	BOTTOM_LEFT,
	TOP_LEFT,
	TOP_RIGHT
}

## Overlapping tiles from the World grid
## that a tile from the Dual grid has.
const NEIGHBOURS := {
	direction.TOP  : TileSet.CellNeighbor.CELL_NEIGHBOR_TOP_SIDE,
	direction.LEFT : TileSet.CellNeighbor.CELL_NEIGHBOR_LEFT_SIDE,
	direction.RIGHT : TileSet.CellNeighbor.CELL_NEIGHBOR_RIGHT_SIDE,
	direction.BOTTOM  : TileSet.CellNeighbor.CELL_NEIGHBOR_BOTTOM_SIDE,
	direction.TOP_LEFT  : TileSet.CellNeighbor.CELL_NEIGHBOR_TOP_LEFT_CORNER,
	direction.BOTTOM_RIGHT : TileSet.CellNeighbor.CELL_NEIGHBOR_BOTTOM_RIGHT_CORNER
}

## Overlapping tiles from the World grid
## that a tile from the Dual grid has.
## To be used ONLY with isometric tilesets.
## CellNighbors are literal, even for Isometric
const NEIGHBOURS_ISOMETRIC := {
	direction.TOP : TileSet.CellNeighbor.CELL_NEIGHBOR_TOP_RIGHT_SIDE,
	direction.LEFT : TileSet.CellNeighbor.CELL_NEIGHBOR_TOP_LEFT_SIDE,
	direction.RIGHT : TileSet.CellNeighbor.CELL_NEIGHBOR_BOTTOM_RIGHT_SIDE,
	direction.BOTTOM  : TileSet.CellNeighbor.CELL_NEIGHBOR_BOTTOM_LEFT_SIDE,
	direction.TOP_LEFT  : TileSet.CellNeighbor.CELL_NEIGHBOR_TOP_CORNER,
	direction.BOTTOM_RIGHT : TileSet.CellNeighbor.CELL_NEIGHBOR_BOTTOM_CORNER
}

## Dict to assign the Atlas coordinates from the
## summation over all sketched NEIGHBOURS.
## Follows the official 2x2 template.
############ SHOULD ALSO WORK FOR ISOMETRIC
const NEIGHBOURS_TO_ATLAS: Dictionary = {
	 0: Vector2i(0,3),
	 1: Vector2i(3,3),
	 2: Vector2i(0,0),
	 3: Vector2i(3,2),
	 4: Vector2i(0,2),
	 5: Vector2i(1,2),
	 6: Vector2i(2,3),
	 7: Vector2i(3,1),
	 8: Vector2i(1,3),
	 9: Vector2i(0,1),
	10: Vector2i(3,0),
	11: Vector2i(2,0),
	12: Vector2i(1,0),
	13: Vector2i(2,2),
	14: Vector2i(1,1),
	15: Vector2i(2,1)
	}

## Coordinates for the fully-filled tile in the Atlas
## that will be used to sketch in the World grid.
## Defaults to the one in the standard Godot template.
## Only this tile will be considered for autotiling.
var full_tile: Vector2i = Vector2i(2,1)
@onready var full_tile_atlas_coord = get_cell_atlas_coords(full_tile)
## The opposed of full_tile.
## Used in-game to erase sketched tiles.
var empty_tile: Vector2i = Vector2i(0,3)
## Prevents checking the cells more than once
## when the entire tileset is being updated,
## which is indicated by checked_cells[0]=true.
## checked_cells[0]=false to overpass this check. 
var checked_cells: Array = [false]
## Track if it is isometric or not
var is_isometric = false
## Keep track of the atlas ID
var _atlas_id: int = 0


func _ready() -> void:
	if debug:
		print('Updating in-game is activated')
	
	#update_tileset()


## Update the entire tileset resource from the dual grid.
## Copies the tileset resource from the world grid,
## displaces itself by half a tile, and updates all tiles.
func update_tileset() -> void:
	if world_tilemap == null:
		if debug:
			print('WARNING: No TileMapLayer connected!')
		return
	
	if debug:
		print('tile_set.tile_shape = ' + str(world_tilemap.tile_set.tile_shape))
	
	if self.tile_set.tile_shape == 1:
		is_isometric = true
		world_tilemap.position.x = - world_tilemap.tile_set.tile_size.x * 0
		world_tilemap.position.y = - world_tilemap.tile_set.tile_size.y * 0.5
	else:
		is_isometric = false
		world_tilemap.position.x = - world_tilemap.tile_set.tile_size.x * 0.5
		world_tilemap.position.y = - world_tilemap.tile_set.tile_size.y * 0.5


## Update all displayed tiles from the dual grid.
## It will only process fully-filled tiles from the world grid.
func _update_tiles() -> void:
	if debug:
		print('Updating tiles....................')
	
	world_tilemap.clear()
	checked_cells = [true]
	for _world_cell in get_used_cells():
		if _is_world_tile_sketched(_world_cell):
			update_tile(_world_cell)
	# checked_cells will only be used when updating
	# the entire tilemap to avoid repeating checks.
	# This check is skipped when updating tiles individually.
	checked_cells = [false]

## Takes a world cell, and updates the
## overlapping tiles from the dual grid accordingly.
func update_tile(world_cell: Vector2i) -> void:
	# Get the atlas ID of this world cell before
	# updating the corresponding tiles
	var id = get_cell_source_id(world_cell)
	if id != -1:
		_atlas_id = id
	
	if debug:
		print('  Updating displayed cells around world cell ' + str(world_cell) + ' with atlas ID ' + str(_atlas_id) + '...')
	
	# Calculate the overlapping cells from the dual grid and update them accordingly
	var neighbors = NEIGHBOURS_ISOMETRIC if is_isometric else NEIGHBOURS
	var _top_left = world_cell
	var _low_left = world_tilemap.get_neighbor_cell(world_cell, neighbors[direction.BOTTOM])
	var _top_right = world_tilemap.get_neighbor_cell(world_cell, neighbors[direction.RIGHT])
	var _low_right = world_tilemap.get_neighbor_cell(world_cell, neighbors[direction.BOTTOM_RIGHT])

	
	_update_displayed_tile(_top_left)
	_update_displayed_tile(_low_left)
	_update_displayed_tile(_top_right)
	_update_displayed_tile(_low_right)


func _update_displayed_tile(_display_cell: Vector2i) -> void:
	# Avoid updating cells more than necessary
	if checked_cells[0] == true:
		if _display_cell in checked_cells:
			return
		checked_cells.append(_display_cell)
	#
	if debug:
		print('    Checking display tile ' + str(_display_cell) + '...')
	
	# INFO: To get the world cells from the dual grid, we apply the opposite vectors
	var neighbors = NEIGHBOURS_ISOMETRIC if is_isometric else NEIGHBOURS
	var _top_left = world_tilemap.get_neighbor_cell(_display_cell, neighbors[direction.TOP_LEFT])
	var _low_left = world_tilemap.get_neighbor_cell(_display_cell, neighbors[direction.LEFT])
	var _top_right = world_tilemap.get_neighbor_cell(_display_cell, neighbors[direction.TOP])
	var _low_right = _display_cell 
	# We perform a bitwise summation over the sketched neighbours
	var _tile_key: int = 0
	if _is_world_tile_sketched(_top_left):
		_tile_key += location.TOP_LEFT
	if _is_world_tile_sketched(_low_left):
		_tile_key += location.LOW_LEFT
	if _is_world_tile_sketched(_top_right):
		_tile_key += location.TOP_RIGHT
	if _is_world_tile_sketched(_low_right):
		_tile_key += location.LOW_RIGHT
	
	var _coords_atlas: Vector2i = NEIGHBOURS_TO_ATLAS[_tile_key]
	world_tilemap.set_cell(_display_cell, _atlas_id, _coords_atlas)
	if debug:
		print('    Display tile ' + str(_display_cell) + ' updated with key ' + str(_tile_key))


func _is_world_tile_sketched(_world_cell: Vector2i) -> bool:
	var _atlas_coords = get_cell_atlas_coords(_world_cell)
	if _atlas_coords == full_tile:
		if debug:
			print('      World cell ' + str(_world_cell) + ' IS sketched with atlas coords ' + str(_atlas_coords))
		return true
	elif _atlas_coords == empty_tile:
		erase_cell(_world_cell)
	else:
		# If the cell is empty, get_cell_atlas_coords() returns (-1,-1)
		if Vector2(_atlas_coords) == Vector2(-1,-1):
			if debug:
				print('      World cell ' + str(_world_cell) + ' Is EMPTY')
		if debug:
			print('      World cell ' + str(_world_cell) + ' Is NOT sketched with atlas coords ' + str(_atlas_coords))
	return false


## Public method to add a tile in a given World cell
func fill_tile(world_cell, atlas_id=0) -> void:
	if world_tilemap == null:
		if debug:
			print('WARNING: No TileMapLayer connected!')
		return
	
	set_cell(world_cell, atlas_id, full_tile)
	update_tile(world_cell)

## Public method to erase a tile in a given World cell
func erase_tile(world_cell, atlas_id=0) -> void:
	if world_tilemap == null:
		if debug:
			print('WARNING: No TileMapLayer connected!')
		return
	
	set_cell(world_cell, atlas_id, empty_tile)
	update_tile(world_cell)


func _process(_delta: float) -> void:
	set_world_tilemap()
	
	var size = tile_map_data.size()
	if map_size != size:
		update_tileset()
		if size < map_size:
			if debug:
				print("Remove cells")
			remove_tiles()
		else:
			if debug:
				print("Add cells")
			add_tiles()
		map_size = size
		

# Remove a cell and replace the ones around for autotiling
func remove_tiles() -> void:
	var remove_cells = used_cache.keys().filter(func(cell): return !get_cell_tile_data(cell))
	var neighbors = NEIGHBOURS_ISOMETRIC if is_isometric else NEIGHBOURS
	for cell in remove_cells:
		used_cache.erase(cell)
		var tile_map = world_tilemap.get_cell_tile_data(cell)
		if tile_map:
			var start_cell = get_neighbor_cell(cell, neighbors[direction.TOP_LEFT])
			for row in 3:
				var current_cell = start_cell
				for col in 3:
					update_tile(current_cell)
					current_cell = get_neighbor_cell(current_cell, neighbors[direction.RIGHT])
				start_cell = get_neighbor_cell(start_cell, neighbors[direction.BOTTOM])

func add_tiles():
	var add_cells = {}
	for cell in get_used_cells():
		if !used_cache.has(cell):
			used_cache[cell] = true
			update_tile(cell)
			
		
func set_world_tilemap() -> void:
	if !self.material:
		# Make this map invisible without disabling it
		self.material = CanvasItemMaterial.new()
		self.material.light_mode = CanvasItemMaterial.LightMode.LIGHT_MODE_LIGHT_ONLY
	# Create offset tileset once TileSet has been created
	if self.tile_set:
		if !get_node_or_null("WorldTileMap"):
			# Add in visible layer
			if world_tilemap:
				tile_map_data = world_tilemap.tile_map_data
			world_tilemap = TileMapLayer.new()
			world_tilemap.name = "WorldTileMap"
			add_child(world_tilemap)
		if world_tilemap.tile_set != self.tile_set:
			world_tilemap.tile_set = self.tile_set
