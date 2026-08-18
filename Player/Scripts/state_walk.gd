class_name State_Walk extends State

@export var move_speed : float = 100.0
@export_range(0.0, 1.0) var diagonal_speed_multiplier: float = 0.9
@onready var idle: State = $"../Idle"
@onready var attack: State = $"../Attack"


func Enter() -> void:
	player.UpdateAnimation("walk")
	pass
	
func Exit() -> void:
	pass
	
func Process(_delta: float) -> State:
	if player.direction == Vector2.ZERO:
		return idle
		
	var speed_multiplier := diagonal_speed_multiplier if player.direction.x != 0.0 and player.direction.y != 0.0 else 1.0
	player.velocity = player.direction * move_speed * speed_multiplier * player.speed_multiplier
	
	if player.SetDirection():
		player.UpdateAnimation("walk")
	return null

func Physics(_delta: float) -> State:
	return null
	
func HandleInput(_event: InputEvent) -> State:
	if _event.is_action_pressed("attack"):
		player.FaceMouseForAttack(_event)
		return attack
	return null
