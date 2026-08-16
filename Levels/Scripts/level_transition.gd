@tool
class_name LevelTransition extends Area2D

enum SIDE {LEFT, RIGHT, TOP, BOTTOM}

@export_file("*.tscn") var level
@export var target_transition_area: String
@export_range(1.0, 128.0, 1.0) var player_entry_distance: float = 48.0

@export_category("Collision Area Settings")

@export_range(1, 12, 1, "or_greater") var size: int = 2 :
	set(v):
		size = v
		update_area()
		

@export var side: SIDE = SIDE.LEFT :
	set(v):
		side = v
		update_area()
		
@onready var collision_shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	update_area()
	
	if Engine.is_editor_hint():
		return
	
	monitoring = false
	place_player()
	
	await LevelManager.level_loaded
	
	monitoring = true
	body_entered.connect(player_entered)
	pass
	
func player_entered(body: Node2D) -> void:
	if body != PlayerManager.player or not monitoring:
		return
	if level.is_empty():
		push_error("%s has no destination level configured." % get_path())
		return
	if target_transition_area.is_empty():
		push_error("%s has no target transition configured." % get_path())
		return

	# Disable immediately so overlapping physics frames cannot start two loads.
	monitoring = false
	LevelManager.load_new_level(level, target_transition_area, get_offset())
	pass	
	
func place_player() -> void:
	if name != LevelManager.target_transition:
		return

	var entry_offset := LevelManager.position_offset
	# Preserve the player's position along the doorway, but always place them on
	# the inside of this destination transition.
	if side == SIDE.LEFT or side == SIDE.RIGHT:
		entry_offset.x = player_entry_distance if side == SIDE.LEFT else -player_entry_distance
	else:
		entry_offset.y = player_entry_distance if side == SIDE.TOP else -player_entry_distance

	PlayerManager.set_player_position(
		global_position + entry_offset
	)
	
	
func get_offset() -> Vector2:
	var offset: Vector2 = Vector2.ZERO
	var player_pos = PlayerManager.player.global_position
	
	if side == SIDE.LEFT || side == SIDE.RIGHT:
		offset.y = player_pos.y - global_position.y
	else:
		offset.x = player_pos.x - global_position.x
	
	return offset
	
func update_area() -> void:
	var new_rect: Vector2 = Vector2(32, 32)
	var new_position: Vector2 = Vector2.ZERO
	
	if side == SIDE.TOP:
		new_rect.x *= size
		new_position.y -= 16
	elif side == SIDE.BOTTOM:
		new_rect.x *= size
		new_position.y += 16
	elif side == SIDE.LEFT:
		new_rect.y *= size
		new_position.x -= 16
	elif side == SIDE.RIGHT:
		new_rect.y *= size
		new_position.x += 16
		
	if collision_shape == null:
		collision_shape = get_node("CollisionShape2D")
		
	collision_shape.shape.size = new_rect
	collision_shape.position = new_position
	pass
	
