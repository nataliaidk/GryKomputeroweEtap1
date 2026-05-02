extends Control

var hover_sound := preload("res://assets/sounds/button hover.mp3")

@onready var audio = $AudioStreamPlayerButton
@onready var start_button = $VBoxContainer/Start
@onready var upgrade_button = $VBoxContainer/Upgrade
@onready var save_button = $VBoxContainer/Save
@onready var exit_button = $VBoxContainer/Exit
@onready var primary_vbox = $PrimaryVBox
@onready var newgame_button = $PrimaryVBox/NewGame
@onready var load_primary_button = $PrimaryVBox/LoadPrimary
@onready var exit_primary_button = $PrimaryVBox/ExitPrimary

func _ready():
	# start with primary menu visible
	primary_vbox.visible = true
	$VBoxContainer.visible = false
	# If another screen requested opening the secondary menu, honor it
	if is_instance_valid(PlayerStats) and PlayerStats.show_secondary_on_open:
		primary_vbox.visible = false
		$VBoxContainer.visible = true
		start_button.grab_focus()
		PlayerStats.show_secondary_on_open = false
	# connect primary buttons
	newgame_button.mouse_entered.connect(_on_hover)
	load_primary_button.mouse_entered.connect(_on_hover)
	exit_primary_button.mouse_entered.connect(_on_hover)
	newgame_button.focus_entered.connect(_on_hover)
	exit_primary_button.focus_entered.connect(_on_hover)
	newgame_button.grab_focus()

	start_button.mouse_entered.connect(_on_hover)
	upgrade_button.mouse_entered.connect(_on_hover)
	save_button.mouse_entered.connect(_on_hover)
	exit_button.mouse_entered.connect(_on_hover)
	start_button.focus_entered.connect(_on_hover)
	upgrade_button.focus_entered.connect(_on_hover)
	save_button.focus_entered.connect(_on_hover)
	exit_button.focus_entered.connect(_on_hover)
	start_button.focus_neighbor_bottom = upgrade_button.get_path()
	upgrade_button.focus_neighbor_bottom = save_button.get_path()
	save_button.focus_neighbor_bottom = exit_button.get_path()
	exit_button.focus_neighbor_top = save_button.get_path()
	
	# keep focus handling: Start gets focus when secondary is shown

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game/game.tscn")

func _on_newgame_pressed() -> void:
	# Reset player stats and show secondary menu (Play/Upgrade/Save/Exit)
	if is_instance_valid(PlayerStats):
		PlayerStats.reset_to_defaults()
	primary_vbox.visible = false
	$VBoxContainer.visible = true
	start_button.grab_focus()

func _on_upgrade_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game/upgrade_screen.tscn")

func _on_save_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game/save_screen.tscn")

func _on_load_pressed() -> void:
	# Always open the load screen so user can pick a save to load upgrades
	get_tree().change_scene_to_file("res://scenes/game/load_screen.tscn")

func _on_exit_pressed() -> void:
	# If secondary menu is visible, go back to primary menu; otherwise quit
	if $VBoxContainer.visible:
		$VBoxContainer.visible = false
		primary_vbox.visible = true
		newgame_button.grab_focus()
	else:
		get_tree().quit()

func _on_hover():
	audio.stream = hover_sound
	audio.play()
