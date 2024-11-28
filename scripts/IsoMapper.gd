@tool
extends Node2D
## Create the scene and add the input image
## and the mask texture in the inspector. Run the scene to
## generate the image and it will save into the output_path

## Start the slicing
@export var build_now: bool = false : set = build
## Input tileset, to slice
@export var input_tileset: Texture2D
## Single tile, to be used for masking
@export var input_mask: Texture2D
@export var output_path: String
@export var grid_side: int = 4

# these values will be calculated automatically
@onready var grid_width := 4
@onready var grid_height := 4
@onready var tile_size := Vector2i(64, 32)
@onready var iso_positions: Array[Vector2i] = [
	Vector2i(3, 0), Vector2i(2,1), Vector2i(1,2), Vector2i(0,3),
	Vector2i(4, 1), Vector2i(3,2), Vector2i(2,3), Vector2i(1,4),
	Vector2i(5, 2), Vector2i(4,3), Vector2i(3,4), Vector2i(2,5),
	Vector2i(6, 3), Vector2i(5,4), Vector2i(4,5), Vector2i(3,6),
]
@onready var grid_position: Array[Vector2i] = [
	Vector2i(0,0), Vector2i(0,1), Vector2i(0,2), Vector2i(0,3),
	Vector2i(1,0), Vector2i(1,1), Vector2i(1,2), Vector2i(1,3),
	Vector2i(2,0), Vector2i(2,1), Vector2i(2,2), Vector2i(2,3),
	Vector2i(3,0), Vector2i(3,1), Vector2i(3,2), Vector2i(3,3),
]
@onready var slices: Array[Image]
@onready var new_image: Image

var transformations: Dictionary


func _ready() -> void:
	pass
#	build_slices()
#	build_new_image()


func build(x) -> bool:
	transformations = calculate_transformations(grid_side)
	build_slices()
	build_new_image()
	return false


func calculate_transformations(side) -> Dictionary:
	var i_new: int
	var j_new: int
	for i in range(0, side-1):
		i_new = i
		j_new = i + side - 1
		for j in range(0, side-1):
			transformations[Vector2i(i, j)] = Vector2i(j_new,i_new)
			i_new += 1
			j_new -= 1
	return transformations


func build_slices() -> void:
	# Check we have the resourcecs to do this or exit
	if not input_tileset:
		return
	if not input_mask:
		return
	
	# Convert the resources to Image resources
	var input_image := input_tileset.get_image()
	var mask_image := input_mask.get_image()
	
	var tile_height = input_image.get_height() / grid_side
	var tile_width = input_image.get_width() / grid_side
	tile_size = Vector2i(tile_width, tile_height)
	
	# Could probably work the positions out by code... but why bother
	for slice_position in iso_positions:
		
		# Create an empty image the size of a tile
		var new_slice := Image.create_empty(tile_size.x, tile_size.y, false, input_image.get_format())
		
		# Blit (copy) the rect onto the new image
		var blit_position := slice_position * (tile_size / 2)
		var slice_rect := Rect2i(blit_position, Vector2i(tile_size.x, tile_size.y))
		new_slice.blit_rect(input_image, slice_rect, Vector2i(0,0))
		
		# Mask the blitted slice, needs to happen after because the size needs to be the same.
		var masked_slice := Image.create_empty(tile_size.x, tile_size.y, false, input_image.get_format())
		var mask_rect := Rect2i(Vector2i(0,0), tile_size)
		masked_slice.blit_rect_mask(new_slice, mask_image, mask_rect, Vector2i(0,0))
		
		# Add it to an array for later use
		slices.append(masked_slice)


func build_new_image() -> void:
	# Check we have image slice
	if slices.size() == 0:
		return
	
	# Create new image that's blank. The RGBA8 format should preserve alpha but I havent tested yet
	new_image = Image.create_empty(grid_width * tile_size.x, grid_height * tile_size.y, false, Image.FORMAT_RGBA8)
	
	# Loop through the slices to build the image in grid order. Again just using array positions for speed
	var i := 0
	for slice in slices:
		# Dst is the position on the new image, rect is the tile size
		var dst := grid_position[i] * tile_size
		var slice_rect = Rect2i(Vector2i(0,0), tile_size)
		new_image.blit_rect(slice, slice_rect, dst)
		i += 1
	
	if output_path:
		# Save to a file. You could add a filename export if you wanted to
		new_image.save_png(output_path + "/output.png")
