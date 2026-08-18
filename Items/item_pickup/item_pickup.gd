@tool 
class_name ItemPickup extends CharacterBody2D

@export var item_data: ItemData : set = set_item_data

@onready var sprite_2d: Sprite2D = $Sprite2D
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
				item_picked_up()
			
	pass
	
func item_picked_up() -> void:
	area_2d.body_entered.disconnect(on_body_entered)
	audio_stream_player_2d.play()
	sprite_2d.visible = false
	await audio_stream_player_2d.finished
	queue_free()
	pass
	
func update_texture() -> void:
	if item_data && sprite_2d:
		sprite_2d.texture = item_data.texture
	pass
	
