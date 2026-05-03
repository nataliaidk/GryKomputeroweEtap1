extends Control

var hover_sound := preload("res://assets/sounds/button hover.mp3")

@export var heroes: Array[HeroData] = []

@onready var audio = $AudioStreamPlayerButton
@onready var start_button := %StartButton1
@onready var stat_label11 := %StatLabel11
@onready var stat_label12 := %StatLabel12
@onready var stat_label13 := %StatLabel13
@onready var name_label := %NameLabel1
@onready var icon := %Icon1
@onready var back_button = $VBoxContainer/Back

func _ready() -> void:
	start_button.mouse_entered.connect(_on_hover)
	back_button.mouse_entered.connect(_on_hover)
	start_button.focus_entered.connect(_on_hover)
	back_button.focus_entered.connect(_on_hover)
	start_button.focus_neighbor_bottom = back_button.get_path()
	back_button.focus_neighbor_top = start_button.get_path()
	start_button.grab_focus()
	_select(0)

func _select(index: int) -> void:
	var h = heroes[index]
	var i = index
	name_label.text = h.hero_name
	stat_label11.text = "HP: %d" % SaveManager.get_stat(i, "max_health", h.max_health)
	stat_label12.text = "SPEED: %d" % SaveManager.get_stat(i, "speed", h.speed)
	stat_label13.text = "LUCK: %d" % SaveManager.get_stat(i, "luck", h.luck)
	icon.texture = h.icon

func _on_start_button_1_pressed() -> void:
	SaveManager.selected_hero = heroes[0]
	SaveManager.selected_hero_index = 0
	get_tree().change_scene_to_file("res://scenes/game/game.tscn")

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")

func _on_hover():
	audio.stream = hover_sound
	audio.play()
