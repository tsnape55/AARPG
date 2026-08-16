class_name Player extends CharacterBody2D

var cardinal_direction : Vector2 = Vector2.DOWN
const DIR_4 = [Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT, Vector2.UP] 	
var direction: Vector2 = Vector2.ZERO

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var effect_animation_player: AnimationPlayer = $EffectAnimationPlayer

@onready var sprite: Sprite2D = $Sprite2D
@onready var state_machine: PlayerStateMachine = $StateMachine
@onready var hit_box: HitBox = $HitBox


signal direction_changed(new_direction: Vector2)
signal player_damaged(hurt_box: HurtBox)

var invulernerable: bool = false
var hp : int = 6
var max_hp : int = 6


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
