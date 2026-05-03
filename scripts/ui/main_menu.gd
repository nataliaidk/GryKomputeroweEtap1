extends Control

var hover_sound := preload("res://assets/sounds/button hover.mp3")

@onready var audio = $AudioStreamPlayerButton
@onready var start_button = $VBoxContainer/StartGame
@onready var upgrade_button = $VBoxContainer/Upgrade
@onready var exit_button = $VBoxContainer/Exit
@onready var kills_label = %KillsLabel
@onready var time_label = %TimeLabel
@onready var gold_label = %GoldLabel

func _ready():
	MusicPlayer.set_volume(1.0)
	MusicPlayer.play_music(preload("res://assets/music/Moonlit Melody.mp3"))
	start_button.mouse_entered.connect(_on_hover)
	upgrade_button.mouse_entered.connect(_on_hover)
	exit_button.mouse_entered.connect(_on_hover)
	start_button.focus_entered.connect(_on_hover)
	upgrade_button.focus_entered.connect(_on_hover)
	exit_button.focus_entered.connect(_on_hover)
	start_button.focus_neighbor_bottom = upgrade_button.get_path()
	upgrade_button.focus_neighbor_top = start_button.get_path()
	upgrade_button.focus_neighbor_bottom = exit_button.get_path()
	exit_button.focus_neighbor_top = upgrade_button.get_path()
	start_button.grab_focus()
	
	kills_label.text = str(SaveManager.best_kills)
	time_label.text = "%02d:%02d" % [int(SaveManager.best_time) / 60, int(SaveManager.best_time) % 60]
	gold_label.text = str(SaveManager.gold)

func _on_start_game_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/hero_selection.tscn")

func _on_upgrade_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/upgrade_screen.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_hover():
	audio.stream = hover_sound
	audio.play()
