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


@export var timer_cooldown: float = 1.0
var _timer: float = 0.0
func _process(delta: float) -> void: # Only used inside the editor
	if timer_cooldown < 0.0:
		return
	if _timer > 0:
		_timer -= delta
		return
	_timer = timer_cooldown
	call_deferred('_changed')


## Called by signals when the tileset changes,
## or by _process inside the editor.
func _changed() -> void:
	_tileset_watcher.update(tile_set)
	_display.update(self)


## Public method to add and remove tiles, as
## TileMapDual.draw(cell, tile, atlas_id).
## 'cell' is a vector with the cell position.
## 'tile' is 1 to draw the full tile (default), 0 to draw the empty tile,
## and -1 to completely remove the tile.
## 'atlas_id' is the atlas id of the tileset to modify, 0 by default.
## This method replaces the deprecated 'fill_tile' and 'erase_tile' methods.
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
