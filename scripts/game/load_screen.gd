extends Control

@onready var back_button = $VBoxContainer/BackButton
@onready var hover_sound = preload("res://assets/sounds/button hover.mp3")
@onready var audio = $AudioStreamPlayerButton
@onready var slot_container = $VBoxContainer/SlotsContainer

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# Wait for autoloads to initialize
	await get_tree().process_frame
	await get_tree().process_frame  # Extra frame for autoloads
	
	if not back_button.pressed.is_connected(_on_back_pressed):
		back_button.pressed.connect(_on_back_pressed)
	back_button.mouse_entered.connect(_on_hover)
	back_button.focus_entered.connect(_on_hover)
	
	# Create load buttons for each slot
	for i in range(3):
		var save_info = PlayerStats.get_save_info(i)
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(500, 60)
		
		if save_info.get("exists", false):
			btn.text = "Slot %d - HP: %d | DMG: %d | Gold: %d" % [
				i + 1,
				save_info.get("health", 0),
				save_info.get("damage", 0),
				save_info.get("gold", 0)
			]
		else:
			btn.text = "Slot %d - Empty" % (i + 1)
		
		btn.pressed.connect(func(): _on_load_slot(i))
		btn.mouse_entered.connect(_on_hover)
		btn.focus_entered.connect(_on_hover)
		slot_container.add_child(btn)
		
		if i == 0:
			btn.grab_focus()

func _on_load_slot(slot: int) -> void:
	PlayerStats.load_slot(slot)
	if is_instance_valid(PlayerStats):
		PlayerStats.show_secondary_on_open = true
	get_tree().change_scene_to_file("res://scenes/game/main_menu.tscn")

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game/main_menu.tscn")

func _on_hover() -> void:
	audio.stream = hover_sound
	audio.play()
