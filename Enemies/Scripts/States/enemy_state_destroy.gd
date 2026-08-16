class_name EnemyStateDestroy extends EnemyState

@export var anim_name : String = "destroy"
@export var knockback_speed: float = 200.0
@export var decelerate_speed: float = 10.0

var _direction : Vector2
var _animation_finished: bool = false

func init() -> void:
	enemy.enemy_destroyed.connect(_on_enemy_destroyed)
	
func enter() -> void:
	enemy.invulernable = true
	_direction = enemy.player.global_position.direction_to(enemy.global_position)
	
	enemy.set_direction(_direction)
	enemy.velocity = knockback_speed * _direction
	
	enemy.update_animation(anim_name)
	enemy.animation_player.animation_finished.connect(_on_animation_finished)
	pass
	
func exit() -> void:
	pass
	
func process(delta: float) -> EnemyState:
	enemy.velocity -= enemy.velocity * decelerate_speed * delta
	return null
	
func physics(_delta: float) -> EnemyState:
	return null
	
func _on_enemy_destroyed() -> void:
	state_machine.change_state(self)
	
func _on_animation_finished(_a: String) -> void:
	enemy.queue_free()
	
