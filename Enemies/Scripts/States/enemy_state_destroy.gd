class_name EnemyStateDestroy extends EnemyState

const PICKUP = preload("res://Items/item_pickup/item_pickup.tscn")

@export var anim_name : String = "destroy"
@export var knockback_speed: float = 200.0
@export var decelerate_speed: float = 10.0
@onready var hurt_box: HurtBox = $"../../HurtBox"

@export_category("Item Drops")
@export var drops: Array[DropData]



var _damage_position: Vector2
var _direction : Vector2

func init() -> void:
	enemy.enemy_destroyed.connect(_on_enemy_destroyed)
	
func enter() -> void:
	enemy.invulernable = true
	hurt_box.monitoring = false
	_direction = enemy.player.global_position.direction_to(_damage_position)
	
	enemy.set_direction(_direction)
	enemy.velocity = knockback_speed * _direction
	
	enemy.update_animation(anim_name)
	enemy.animation_player.animation_finished.connect(_on_animation_finished)
	disable_hurt_box()
	drop_items()
	pass
	
func exit() -> void:
	pass
	
func process(delta: float) -> EnemyState:
	enemy.velocity -= enemy.velocity * decelerate_speed * delta
	return null
	
func physics(_delta: float) -> EnemyState:
	return null
	
func _on_enemy_destroyed(_hurt_box: HurtBox) -> void:
	_damage_position = _hurt_box.global_position
	state_machine.change_state(self)
	
func _on_animation_finished(_a: String) -> void:
	enemy.queue_free()
	
func disable_hurt_box() -> void:
	var current_hurt_box: HurtBox = enemy.get_node_or_null("HurtBox")
	if current_hurt_box:
		current_hurt_box.monitoring = false
		
func drop_items() -> void:
	if drops.size() == 0:
		return
		
	for i in drops.size():
		if drops[i] == null || drops[i].item == null:
			continue
		else:
			var drop_count: int = drops[i].get_drop_count()
			for j in drop_count:
				var drop: ItemPickup = PICKUP.instantiate() as ItemPickup
				drop.item_data = drops[i].item
				enemy.get_parent().call_deferred("add_child", drop)
				drop.global_position = enemy.global_position
				drop.velocity = enemy.velocity.rotated(randf_range(-1.5, 1.5)) * randf_range(0.9, 1.5)
		
	
