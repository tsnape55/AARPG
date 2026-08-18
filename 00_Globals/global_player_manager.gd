extends Node

const PLAYER = preload("uid://bf4esf57fcnh8")
const INVENTORY_DATA : InventoryData = preload("uid://b178vcvcbous1")

var player: Player
var player_spawned: bool = false

func _ready() -> void:
	add_player_instance()
	await get_tree().create_timer(0.2).timeout
	player_spawned = true

func add_player_instance() -> void:
	player = PLAYER.instantiate()
	add_child(player)
	pass
	
func set_player_health(hp: int, max_hp: int) -> void:
	player.max_hp = max_hp
	player.hp = hp
	player.update_hp(0)
	pass	
	
func set_player_position(new_pos: Vector2) -> void:
	player.global_position = new_pos
	pass

func set_as_parent(p: Node2D) -> void:
	if player.get_parent():
		player.get_parent().remove_child(player)
	p.add_child(player)
	pass
	
func unparent_player(p: Node2D) -> void:
	p.remove_child(player)
	
