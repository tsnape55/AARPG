@tool 
class_name ItemPickup extends CharacterBody2D

@export var item_data: ItemData : set = set_item_data

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var shadow_sprite_2d: Sprite2D = $ShadowSprite2D
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var area_2d: Area2D = $Area2D

func _ready() -> void:
	update_texture()
	if Engine.is_editor_hint():
		return

	area_2d.body_entered.connect(on_body_entered)	
	
	pass
	
func _physics_process(delta: float) -> void:
	var collision_info = move_and_collide(velocity * delta)
	if collision_info:
		velocity = velocity.bounce(collision_info.get_normal())
	velocity -= velocity * delta * 4
		

func set_item_data(value: ItemData) -> void:
	update_texture()
	item_data = value
	pass
	
func on_body_entered(b) -> void:
	if b is Player: 
		if item_data:
			if PlayerManager.INVENTORY_DATA.add_item(item_data, 1) == true:
				show_pickup_feedback(b)
				item_picked_up()
			
	pass

func show_pickup_feedback(player: Player) -> void:
	var feedback := Node2D.new()
	feedback.position = Vector2(0, -28)
	feedback.z_index = 100
	player.add_child(feedback)

	var icon := Sprite2D.new()
	icon.texture = item_data.texture
	icon.modulate.a = 0.6
	icon.scale = Vector2(0.75, 0.75)
	feedback.add_child(icon)

	var amount_label := Label.new()
	amount_label.text = "+1"
	amount_label.position = Vector2(10, -7)
	amount_label.add_theme_font_size_override("font_size", 8)
	amount_label.add_theme_color_override("font_outline_color", Color.BLACK)
	amount_label.add_theme_constant_override("outline_size", 2)
	feedback.add_child(amount_label)

	var tween := feedback.create_tween().set_parallel()
	tween.tween_property(feedback, "position:y", -42.0, 0.7)
	tween.tween_property(feedback, "modulate:a", 0.0, 0.7)
	tween.chain().tween_callback(feedback.queue_free)
	
func item_picked_up() -> void:
	area_2d.body_entered.disconnect(on_body_entered)
	audio_stream_player_2d.play()
	sprite_2d.visible = false
	shadow_sprite_2d.visible = false
	await audio_stream_player_2d.finished
	queue_free()
	pass
	
func update_texture() -> void:
	if item_data && sprite_2d:
		sprite_2d.texture = item_data.texture
	pass
	
