@tool
@icon('TileMapDual.svg')
class_name TileMapDual
extends TileMapLayer


var _tileset_watcher: TileSetWatcher
var _display: Display
func _ready() -> void:
	_tileset_watcher = TileSetWatcher.new(tile_set)
	_tileset_watcher.atlas_added.connect(_atlas_added, 1)
	_display = Display.new(_tileset_watcher)
	add_child(_display)
	_make_self_invisible()
	if Engine.is_editor_hint():
		set_process(true)
	else: # Run in-game using signals for better performance
		set_process(false)
		changed.connect(_changed, 1)


func _atlas_added(source_id: int, atlas: TileSetAtlasSource):
	#TerrainDual.write_default_preset(_tileset_watcher.tile_set, atlas)
	pass


## Sets up the Dual-Grid illusion.
## Called on ready.
func _make_self_invisible() -> void:
	material = CanvasItemMaterial.new()
	material.light_mode = CanvasItemMaterial.LightMode.LIGHT_MODE_LIGHT_ONLY


@export var map_refresh_cooldown: float = 0.0
var _timer: float = 0.0
func _process(delta: float) -> void: # Only used inside the editor
	if map_refresh_cooldown < 0.0:
		return
	if _timer > 0:
		_timer -= delta
		return
	_timer = map_refresh_cooldown
	call_deferred('_changed')


## Called by signals when the tileset changes,
## or by _process inside the editor.
func _changed() -> void:
	_tileset_watcher.update(tile_set)
	_display.update(self)


## Public method to add and remove tiles.
##
## 'cell' is a vector with the cell position.
## 'terrain' is which terrain type to draw.
## terrain -1 completely removes the tile,
## and by default, terrain 0 is the empty tile.
func draw(cell: Vector2i, terrain: int = 1) -> void:
	var terrains := _display.terrain.terrains
	if terrain not in terrains:
		erase_cell(cell)
		return
	var tile_to_use: Dictionary = terrains[terrain]
	var sid: int = tile_to_use.sid
	var tile: Vector2i = tile_to_use.tile
	set_cell(cell, sid, tile)
	changed.emit()
