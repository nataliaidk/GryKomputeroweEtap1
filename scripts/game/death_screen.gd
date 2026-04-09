extends Control

@onready var timer_label = $TimerLabel

func _ready():
	timer_label.text = "Survived for %02d' %02ds" % [int(GameTimer.seconds()) / 60, int(GameTimer.seconds()) % 60]

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game/main_menu.tscn")
