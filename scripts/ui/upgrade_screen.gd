extends Control

@onready var icon := %Icon1
@onready var name_label := %NameLabel1
@onready var gold_label: Label = %GoldLabel
@onready var health_label: Label = %HealthLabel
@onready var speed_label: Label = %SpeedLabel
@onready var luck_label: Label = %LuckLabel
@onready var health_button: Button = %HealthButton
@onready var speed_button: Button = %SpeedButton
@onready var luck_button: Button = %LuckButton
@onready var back_button: Button = $VBoxContainer/Back
@onready var health_segments: Container = %HealthSegments
@onready var speed_segments: Container = %SpeedSegments
@onready var luck_segments: Container = %LuckSegments
@onready var hover_sound = preload("res://assets/sounds/button hover.mp3")
@onready var audio = $AudioStreamPlayerButton

const UPGRADE_COST = 50

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	SaveManager.gold_changed.connect(_update_ui)
	SaveManager.stats_changed.connect(_update_ui)
	health_button.pressed.connect(_on_upgrade_health)
	speed_button.pressed.connect(_on_upgrade_speed)
	luck_button.pressed.connect(_on_upgrade_luck)
	back_button.pressed.connect(_on_back_pressed)
	for btn in [health_button, speed_button, luck_button, back_button]:
		btn.mouse_entered.connect(_on_hover)
		btn.focus_entered.connect(_on_hover)
	_update_ui()
	back_button.grab_focus()

func _update_ui() -> void:
	var h = SaveManager.all_heroes[0]
	var i = 0
	icon.texture = h.icon
	name_label.text = h.hero_name
	gold_label.text = str(SaveManager.gold)
	health_label.text = "HP: %d" % [SaveManager.get_stat(i, "max_health", h.max_health)]
	speed_label.text = "SPEED: %d" % [SaveManager.get_stat(i, "speed", h.speed)]
	luck_label.text = "LUCK: %d" % [SaveManager.get_stat(i, "luck", h.luck)]
	health_button.disabled = SaveManager.gold < UPGRADE_COST or SaveManager.get_level(i, "max_health") >= 10
	speed_button.disabled = SaveManager.gold < UPGRADE_COST or SaveManager.get_level(i, "speed") >= 10
	luck_button.disabled = SaveManager.gold < UPGRADE_COST or SaveManager.get_level(i, "luck") >= 10
	draw_segments(health_segments, SaveManager.get_level(0, "max_health"))
	draw_segments(speed_segments, SaveManager.get_level(0, "speed"))
	draw_segments(luck_segments, SaveManager.get_level(0, "luck"))

func _on_upgrade_health() -> void:
	SaveManager.upgrade_hero_stat(SaveManager.selected_hero_index, "max_health", UPGRADE_COST)

func _on_upgrade_speed() -> void:
	SaveManager.upgrade_hero_stat(SaveManager.selected_hero_index, "speed", UPGRADE_COST)

func _on_upgrade_luck() -> void:
	SaveManager.upgrade_hero_stat(SaveManager.selected_hero_index, "luck", UPGRADE_COST)

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")

func _on_hover() -> void:
	audio.stream = hover_sound
	audio.play()

func draw_segments(container: HBoxContainer, level: int, max_level: int = 10) -> void:
	for child in container.get_children():
		child.queue_free()
	
	for i in max_level:
		var segment = ColorRect.new()
		segment.custom_minimum_size = Vector2(8, 8)
		segment.color = Color(0.6, 0.1, 0.1) if i < level else Color(0.2, 0.2, 0.2)
		container.add_child(segment)
