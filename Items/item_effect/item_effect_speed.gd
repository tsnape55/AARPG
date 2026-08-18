class_name ItemEffectSpeed extends ItemEffect

@export var speed_increase_percent : int = 30
@export var speed_increase_duration: int = 10
@export var sound: AudioStream

func use() -> void:
	PlayerManager.player.update_speed(speed_increase_percent, speed_increase_duration)
	PauseMenu.play_audio(sound)
	pass
