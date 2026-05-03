extends Node2D

const PAUSE_SCENE := preload("res://scenes/ui/pause_screen.tscn")

const TRACKS = [
	preload("res://assets/music/Before Concession.mp3"),
	preload("res://assets/music/Unholy Invocation.mp3")
]

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	MusicPlayer.set_volume(0.2)
	MusicPlayer.play_music(TRACKS.pick_random())
	GameData.kills = 0
	GameData.gold = 0

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and not get_tree().paused:
			get_tree().paused = true
			var pause := PAUSE_SCENE.instantiate()
			get_tree().root.add_child(pause)
