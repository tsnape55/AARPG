extends Node

signal level_load_started
signal level_loaded
signal TileMapBoundsChanged(bounds: Array[Vector2])

var current_tilemap_bounds : Array [Vector2]
var target_transition : String
var position_offset: Vector2
var is_loading: bool = false

func _ready() -> void:
	await get_tree().process_frame
	level_loaded.emit()
	pass

func ChangeTileMapBounds(bounds: Array[Vector2]) -> void:
	current_tilemap_bounds = bounds
	TileMapBoundsChanged.emit(bounds)
	pass

func load_new_level(
	level_path: String,
	_target_transition: String,
	_position_offset: Vector2
) -> void:
	if is_loading:
		return
	if not ResourceLoader.exists(level_path, "PackedScene"):
		push_error("Cannot load level scene: %s" % level_path)
		return

	is_loading = true
	get_tree().paused = true
	target_transition = _target_transition
	position_offset = _position_offset
	
	print("LEVEL TRANSITION", target_transition, position_offset)
	
	await SceneTransition.fade_out()
	
	level_load_started.emit()
	
	await get_tree().process_frame
	
	var change_error := get_tree().change_scene_to_file(level_path)
	if change_error != OK:
		push_error("Failed to change scene to %s (error %s)." % [level_path, change_error])
		get_tree().paused = false
		is_loading = false
		return
	
	
	get_tree().paused = false
	is_loading = false
	
	await SceneTransition.fade_in()
	
	await get_tree().process_frame
	
	level_loaded.emit()
	
	pass
