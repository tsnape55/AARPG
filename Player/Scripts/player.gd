class_name Player extends CharacterBody2D

var cardinal_direction : Vector2 = Vector2.DOWN
const DIR_4 = [Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT, Vector2.UP] 	
var direction: Vector2 = Vector2.ZERO
@export_range(0.0, 1.0, 0.05) var controller_diagonal_deadzone: float = 0.35

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var effect_animation_player: AnimationPlayer = $EffectAnimationPlayer

@onready var sprite: Sprite2D = $Sprite2D
@onready var state_machine: PlayerStateMachine = $StateMachine
@onready var hit_box: HitBox = $HitBox


signal direction_changed(new_direction: Vector2)
signal player_damaged(hurt_box: HurtBox)

var invulernerable: bool = false
var hp : int = 12
var max_hp : int = 12


# Called when the node enters the scene tree for the first time
func _ready() -> void:
	PlayerManager.player = self
	state_machine.Initialize(self)
	update_hp(99)
	hit_box.damaged.connect(take_damage)
	pass
	
func _process(_delta: float) -> void:
	direction = Vector2(
		Input.get_axis("left", "right"),
		Input.get_axis("up", "down")
	)

	# Ignore a small secondary stick axis so near-cardinal input stays cardinal.
	# Keyboard and D-pad axes are always 1.0, so their diagonals are unaffected.
	if direction.y != 0.0 and abs(direction.x) < controller_diagonal_deadzone:
		direction.x = 0.0
	if direction.x != 0.0 and abs(direction.y) < controller_diagonal_deadzone:
		direction.y = 0.0

	direction = direction.normalized()
	pass
	
func _physics_process(_delta: float) -> void:
	move_and_slide()
pass

func SetDirection() -> bool:
	if direction == Vector2.ZERO:
		return false
	
	var direction_id : int = int( round((direction + cardinal_direction * 0.1).angle() / TAU * DIR_4.size()))
	
	var new_direction = DIR_4[direction_id]
		
	if new_direction == cardinal_direction:
		return false
		
	cardinal_direction = new_direction
	direction_changed.emit(cardinal_direction)	
	sprite.scale.x = -1 if cardinal_direction == Vector2.LEFT else 1
	  	
	return true

func FaceMouseForAttack(event: InputEvent) -> void:
	if not event is InputEventMouseButton:
		return
	FaceMouseDirection()

func FaceMouseDirection() -> bool:
	var mouse_direction := global_position.direction_to(get_global_mouse_position())
	if mouse_direction == Vector2.ZERO:
		return false

	var new_direction: Vector2
	if abs(mouse_direction.x) >= abs(mouse_direction.y):
		new_direction = Vector2.RIGHT if mouse_direction.x > 0.0 else Vector2.LEFT
	else:
		new_direction = Vector2.DOWN if mouse_direction.y > 0.0 else Vector2.UP

	if new_direction == cardinal_direction:
		return false

	cardinal_direction = new_direction
	direction_changed.emit(cardinal_direction)
	sprite.scale.x = -1 if cardinal_direction == Vector2.LEFT else 1
	return true

func UpdateAnimation(state: String) -> void:
	animation_player.play(state + "_" + AnimDirection())
	pass
	
	
func AnimDirection() -> String:
	if cardinal_direction == Vector2.DOWN:
		return "down"
	elif cardinal_direction ==  Vector2.UP:
		return "up"
	else:
		return "side"
		
func take_damage(hurt_box: HurtBox) -> void:
	if invulernerable:
		return
	
	update_hp(-hurt_box.damage)
	
	if hp > 0:
		player_damaged.emit(hurt_box)
	else:
		player_damaged.emit(hurt_box)
		update_hp(99)
	pass

func update_hp(delta: int) -> void:
	hp = clampi(hp + delta, 0, max_hp)
	PlayerHud.update_hp(hp, max_hp)
	
	pass
	
func make_invulnerable(duration: float = 1.0) -> void:
	invulernerable = true
	hit_box.monitoring = false
	
	await get_tree().create_timer(duration).timeout
	
	invulernerable = false
	hit_box.monitoring = true
	
	pass
