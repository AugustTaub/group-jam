extends Node2D

func _ready():
	AudioServer.set_bus_layout(load("res://misc/audio_bus_layout.tres"))
	SignalBus.game_started.connect(func(): play_audio("gameplay_music"))
	
	SignalBus.play_audio.connect(play_audio)


func play_audio(audio_name: String):
	var found: AudioStreamPlayer2D = find_child(audio_name)
	if found != null:
		found.play()
