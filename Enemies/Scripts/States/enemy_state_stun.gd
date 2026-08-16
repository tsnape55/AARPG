class_name EnemyStateStun extends EnemyState

@export var anim_name : String = "stun"
@export var knockback_speed: float = 200.0
@export var decelerate_speed: float = 10.0

@export_category("AI")
@export var next_state : EnemyState

var _damage_position: Vector2
var _direction : Vector2
var _animation_finished: bool = false

func init() -> void:
	enemy.enemy_damaged.connect(_on_enemy_damaged)
	
func enter() -> void:
	enemy.invulernable = true
	_animation_finished = false
	_direction = enemy.player.global_position.direction_to(_damage_position)
	
	enemy.set_direction(_direction)
	enemy.velocity = knockback_speed * _direction
	
	enemy.update_animation(anim_name)
	enemy.animation_player.animation_finished.connect(_on_animation_finished)
	pass
	
func exit() -> void:
	enemy.invulernable = false
	enemy.animation_player.animation_finished.disconnect(_on_animation_finished)
	pass
	
func process(delta: float) -> EnemyState:
	if _animation_finished == true:
		return next_state
		
	enemy.velocity -= enemy.velocity * decelerate_speed * delta
	return null
	
func physics(_delta: float) -> EnemyState:
	return null
	
func _on_enemy_damaged(_hurt_box: HurtBox) -> void:
	_damage_position = _hurt_box.global_position
	state_machine.change_state(self)
	
func _on_animation_finished(_a: String) -> void:
	_animation_finished = true
	
