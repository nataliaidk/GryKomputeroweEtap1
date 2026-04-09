extends Control

var hover_sound := preload("res://assets/sounds/button hover.mp3")

@onready var audio = $AudioStreamPlayerButton
@onready var start_button = $VBoxContainer/Start
@onready var exit_button = $VBoxContainer/Exit

func _ready():
	start_button.mouse_entered.connect(_on_hover)
	exit_button.mouse_entered.connect(_on_hover)

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game/game.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_hover():
	audio.stream = hover_sound
	audio.play()
