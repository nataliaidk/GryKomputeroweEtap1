extends Control

var hover_sound := preload("res://assets/sounds/button hover.mp3")

@onready var audio = $AudioStreamPlayerButton
@onready var back_button = $VBoxContainer/Back
@onready var timer_label = $HBoxContainer/TimerLabel
@onready var kills_label = $HBoxContainer/KillsContainer/KillsLabel
@onready var gold_label = $HBoxContainer/GoldContainer/GoldLabel

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	MusicPlayer.stop_music()
	
	var survival_time = int(GameTimer.seconds())
	var gold_earned = survival_time + GameData.gold
	SaveManager.add_gold(gold_earned)
	SaveManager.on_game_over(survival_time, GameData.kills)
	
	timer_label.text = "%02d:%02d" % [int(GameTimer.seconds()) / 60, int(GameTimer.seconds()) % 60]
	kills_label.text = "%d" % GameData.kills
	gold_label.text = "+ %d" % gold_earned 

	back_button.mouse_entered.connect(_on_hover)
	back_button.focus_entered.connect(_on_hover)
	back_button.grab_focus()

func _on_hover():
	audio.stream = hover_sound
	audio.play()

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
