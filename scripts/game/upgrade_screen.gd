extends Control

@onready var gold_label: Label = $VBoxContainer/Content/StatsPanel/StatsBox/GoldLabel
@onready var health_label: Label = $VBoxContainer/Content/StatsPanel/StatsBox/HealthRow/HealthLabel
@onready var damage_label: Label = $VBoxContainer/Content/StatsPanel/StatsBox/DamageRow/DamageLabel
@onready var health_button: Button = $VBoxContainer/Content/StatsPanel/StatsBox/HealthRow/UpgradeHealthBtn
@onready var damage_button: Button = $VBoxContainer/Content/StatsPanel/StatsBox/DamageRow/UpgradeDamageBtn
@onready var back_button: Button = $VBoxContainer/Content/StatsPanel/StatsBox/BackButton
@onready var hover_sound = preload("res://assets/sounds/button hover.mp3")
@onready var audio = $AudioStreamPlayerButton

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	await get_tree().process_frame
	await get_tree().process_frame

	if is_instance_valid(PlayerStats):
		if not PlayerStats.gold_changed.is_connected(_update_ui):
			PlayerStats.gold_changed.connect(_update_ui)
		if not PlayerStats.stats_changed.is_connected(_update_ui):
			PlayerStats.stats_changed.connect(_update_ui)

	health_button.pressed.connect(_on_upgrade_health)
	damage_button.pressed.connect(_on_upgrade_damage)
	back_button.pressed.connect(_on_back_pressed)

	for btn in [health_button, damage_button, back_button]:
		btn.mouse_entered.connect(_on_hover)
		btn.focus_entered.connect(_on_hover)

	_update_ui()
	back_button.grab_focus()

func _update_ui() -> void:
	if not is_instance_valid(PlayerStats):
		return

	gold_label.text = "Gold: %d" % PlayerStats.gold
	health_label.text = "HP: %d" % PlayerStats.max_health
	damage_label.text = "DMG: %d" % PlayerStats.damage
	health_button.disabled = PlayerStats.gold < 50
	damage_button.disabled = PlayerStats.gold < 50

func _on_upgrade_health() -> void:
	if PlayerStats.upgrade_health(50):
		_update_ui()

func _on_upgrade_damage() -> void:
	if PlayerStats.upgrade_damage(50):
		_update_ui()

func _on_back_pressed() -> void:
	if is_instance_valid(PlayerStats):
		PlayerStats.show_secondary_on_open = true
	get_tree().change_scene_to_file("res://scenes/game/main_menu.tscn")

func _on_hover() -> void:
	audio.stream = hover_sound
	audio.play()
