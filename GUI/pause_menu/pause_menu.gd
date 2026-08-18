extends CanvasLayer

signal shown
signal hidden

@onready var button_load: Button = $Control/ColorRect/VBoxContainer/Button_Load
@onready var button_save: Button = $Control/ColorRect/VBoxContainer/Button_Save
@onready var item_description: Label = $Control/ItemDescription
@onready var audio_stream_player: AudioStreamPlayer2D = $Control/AudioStreamPlayer2D


var is_paused: bool = false

func _ready() -> void:
	hide_pause_menu()
	button_save.pressed.connect(on_save_press)
	button_load.pressed.connect(on_load_press)
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if is_paused == false:
			show_pause_menu()
			pass
		else:
			hide_pause_menu()
			pass
		get_viewport().set_input_as_handled()
		
func show_pause_menu() -> void:
	get_tree().paused = true
	visible = true
	is_paused = true
	shown.emit()
	

func hide_pause_menu() -> void:
	get_tree().paused = false
	visible = false
	is_paused = false
	hidden.emit()
	
func on_save_press() -> void:
	if is_paused != true:
		return

	SaveManager.save_game()
	
func on_load_press() -> void:
	if is_paused != true:
		return

	SaveManager.load_game()
	await LevelManager.level_load_started
	hide_pause_menu()
	
func update_item_description(new_text: String) -> void:
	item_description.text = new_text
	
func play_audio(sound: AudioStream) -> void:
	audio_stream_player.stream = sound
	audio_stream_player.play()
	pass
