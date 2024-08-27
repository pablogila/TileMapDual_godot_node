@tool
class_name TileMapDual
extends TileMapLayer

## World TileMapLayer.
## An offset of (-0.5,-0.5) tiles will be applied
## with respect to the World grid.
@export var world_tilemap: TileMapLayer
## Coordinates for the tile in the Atlas
## that will be used to draw in the World TileMapLayer.
## Defaults to the one in the official Godot template.
@export var draw_atlas_coord: Vector2i = Vector2i(2,1)

## Bit-wise logic: summing over all neighbours
## provides the proper tile from the Atlas.
enum direction {
	TOP_LEFT  = 1,
	LOW_LEFT  = 2,
	TOP_RIGHT = 4,
	LOW_RIGHT = 8
	}

## Overlapping tiles from the World grid
## that a tile from TileMapDual has.
const NEIGHBOURS := {
	direction.TOP_LEFT  : Vector2(0,0),
	direction.LOW_LEFT  : Vector2(0,1),
	direction.TOP_RIGHT : Vector2(1,0),
	direction.LOW_RIGHT : Vector2(1,1)
	}

## Sum the NEIGHBOURS, and assign the coordinates to the Atlas.
## Folloes the official 2x2 template.
const NEIGHBOURS_TO_ATLAS: Dictionary = {
	 0: Vector2(3,0),
	 1: Vector2(3,3),
	 2: Vector2(0,0),
	 3: Vector2(3,2),
	 4: Vector2(0,1),
	 5: Vector2(1,2),
	 6: Vector2(2,3),
	 7: Vector2(3,1),
	 8: Vector2(1,3),
	 9: Vector2(0,1),
	10: Vector2(0,3),
	11: Vector2(0,2),
	12: Vector2(0,1),
	13: Vector2(2,2),
	14: Vector2(1,1),
	15: Vector2(2,1)
	}


func _ready() -> void:
	world_tilemap.changed.connect(_update_tilemap)


func _update_tilemap() -> void:
	self.tile_set = world_tilemap.tile_set
	self.position.x = - self.tile_set.tile_size.x * 0.5
	self.position.y = - self.tile_set.tile_size.y * 0.5
	_update_tiles()


func _update_tiles() -> void:
	var _cell_coords: Vector2i
	var _cell_atlas_coords: Vector2i
	for _cell in self.get_used_cells():
		_cell_coords = Vector2i(0,0) # placeholder
		_cell_atlas_coords = _calculate_display_tile(_cell_coords)
		self.set_cell(_cell_coords, 0, _cell_atlas_coords)


func _calculate_display_tile(coords: Vector2i) -> Vector2i:
	var top_left = _is_world_tile_drawn(coords - NEIGHBOURS.direction.TOP_LEFT)
	var low_left = _is_world_tile_drawn(coords - NEIGHBOURS.direction.LOW_LEFT)
	var top_right = _is_world_tile_drawn(coords - NEIGHBOURS.direction.TOP_RIGHT)
	var low_right = _is_world_tile_drawn(coords - NEIGHBOURS.direction.LOW_RIGHT)

	var tile_key = 0
	tile_key += top_left * NEIGHBOURS.direction.TOP_LEFT
	tile_key += low_left * NEIGHBOURS.direction.LOW_LEFT
	tile_key += top_right * NEIGHBOURS.direction.TOP_RIGHT
	tile_key += low_right * NEIGHBOURS.direction.LOW_RIGHT
	
	return NEIGHBOURS_TO_ATLAS[tile_key]


func _is_world_tile_drawn(coords: Vector2i) -> int:
	var atlas_coord = get_cell_atlas_coords(coords)
	if atlas_coord == draw_atlas_coord:
		return 1
	else:
		return 0
