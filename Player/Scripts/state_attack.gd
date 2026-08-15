class_name State_Attack extends State
@onready var walk: State = $"../Walk"
@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"
@onready var attack_animation_player: AnimationPlayer = $"../../Sprite2D/AttackEffectSprite/AnimationPlayer"
@onready var attack: State_Attack = $"."
@onready var idle: State = $"../Idle"

@export var attack_sound : AudioStream
@export_range(1, 20, 0.5) var decelerate_speed : float = 5.0
@onready var audio : AudioStreamPlayer2D = $"../../Audio/AudioStreamPlayer2D"

var attacking: bool = false

func Enter() -> void:
	player.UpdateAnimation("attack")
	attack_animation_player.play("attack_" + player.AnimDirection())
	animation_player.animation_finished.connect(EndAttack)
	
	audio.stream = attack_sound
	audio.pitch_scale = randf_range(0.9, 1.1)
	audio.play()
	attacking = true
	pass

func Exit() -> void:
	animation_player.animation_finished.disconnect(EndAttack)
	attacking = false
	pass
	
func Process(_delta: float) -> State:
	player.velocity -= player.velocity * decelerate_speed * _delta
	
	if !attacking:
		if player.direction == Vector2.ZERO:
			return idle
		else:
			return walk
		
	return null

func Physics(_delta: float) -> State:
	return null
	
func HandleInput(_event: InputEvent) -> State:
	return null
	
func EndAttack(_newAnimName: String) -> void:
	attacking = false
