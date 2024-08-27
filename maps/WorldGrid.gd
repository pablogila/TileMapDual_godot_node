@tool
extends Node2D

@onready var dual = $Dual
@onready var world = $World

## Bit-wise logic: summing over all neighbours provides the proper tile
enum direction {
	TOP_LEFT  = 1,
	LOW_LEFT  = 2,
	TOP_RIGHT = 4,
	LOW_RIGHT = 8
	}

## Neighbours from the WorldGrid that a DisplayGrid tile has 
const NEIGHBOURS := {
	direction.TOP_LEFT  : Vector2(0,0),
	direction.LOW_LEFT  : Vector2(0,1),
	direction.TOP_RIGHT : Vector2(1,0),
	direction.LOW_RIGHT : Vector2(1,1)
	}

## Sum the NEIGHBOURS, and assign the coordinates to the Atlas
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

# TO-DO: implement dual-grid tileset system
