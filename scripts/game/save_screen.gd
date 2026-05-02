extends Control

@onready var slots_container: VBoxContainer = $VBoxContainer/SlotsPanel/SlotsContainer
@onready var back_button: Button = $VBoxContainer/BackButton
@onready var audio: AudioStreamPlayer = $AudioStreamPlayerButton
@onready var hover_sound = preload("res://assets/sounds/button hover.mp3")

var _slot_labels: Array[Label] = []
var _save_buttons: Array[Button] = []
var _delete_buttons: Array[Button] = []

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	await get_tree().process_frame
	await get_tree().process_frame

	if not back_button.pressed.is_connected(_on_back_pressed):
		back_button.pressed.connect(_on_back_pressed)
	back_button.mouse_entered.connect(_on_hover)
	back_button.focus_entered.connect(_on_hover)

	_build_slot_rows()
	_refresh_slots()
	back_button.grab_focus()

func _build_slot_rows() -> void:
	for child in slots_container.get_children():
		child.queue_free()
	_slot_labels.clear()
	_save_buttons.clear()
	_delete_buttons.clear()

	for slot in range(3):
		var row := PanelContainer.new()
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var row_style := StyleBoxFlat.new()
		row.add_theme_stylebox_override("panel", row_style)
		row_style.bg_color = Color(0.16, 0.16, 0.16, 0.95)
		row_style.corner_radius_top_left = 14
		row_style.corner_radius_top_right = 14
		row_style.corner_radius_bottom_left = 14
		row_style.corner_radius_bottom_right = 14

		var row_box := HBoxContainer.new()
		row_box.add_theme_constant_override("separation", 14)
		row_box.offset_left = 14.0
		row_box.offset_top = 10.0
		row_box.offset_right = -14.0
		row_box.offset_bottom = -10.0
		row.add_child(row_box)

		var label := Label.new()
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.add_theme_font_override("font", preload("res://assets/fonts/Gothikka.ttf"))
		label.add_theme_font_size_override("font_size", 22)
		label.add_theme_color_override("font_color", Color(1, 1, 1, 1))
		row_box.add_child(label)

		var save_button := Button.new()
		save_button.text = "Save"
		save_button.custom_minimum_size = Vector2(120, 44)
		save_button.add_theme_font_override("font", preload("res://assets/fonts/Gothikka.ttf"))
		save_button.add_theme_font_size_override("font_size", 20)
		save_button.pressed.connect(_on_save_slot.bind(slot))
		save_button.mouse_entered.connect(_on_hover)
		save_button.focus_entered.connect(_on_hover)
		row_box.add_child(save_button)

		var delete_button := Button.new()
		delete_button.text = "Delete"
		delete_button.custom_minimum_size = Vector2(120, 44)
		delete_button.add_theme_font_override("font", preload("res://assets/fonts/Gothikka.ttf"))
		delete_button.add_theme_font_size_override("font_size", 20)
		delete_button.pressed.connect(_on_delete_slot.bind(slot))
		delete_button.mouse_entered.connect(_on_hover)
		delete_button.focus_entered.connect(_on_hover)
		row_box.add_child(delete_button)

		slots_container.add_child(row)
		_slot_labels.append(label)
		_save_buttons.append(save_button)
		_delete_buttons.append(delete_button)

func _refresh_slots() -> void:
	if not is_instance_valid(PlayerStats):
		return

	for slot in range(3):
		var info: Dictionary = PlayerStats.get_save_info(slot)
		var exists: bool = bool(info.get("exists", false))
		if exists:
			_slot_labels[slot].text = "Slot %d  |  HP %d  |  DMG %d  |  Gold %d" % [
				slot + 1,
				int(info.get("health", 0)),
				int(info.get("damage", 0)),
				int(info.get("gold", 0))
			]
		else:
			_slot_labels[slot].text = "Slot %d  |  Empty" % (slot + 1)

		_save_buttons[slot].text = "Save Here"
		_delete_buttons[slot].disabled = not exists

func _on_save_slot(slot: int) -> void:
	if PlayerStats.save_slot(slot):
		if is_instance_valid(PlayerStats):
			PlayerStats.show_secondary_on_open = true
		get_tree().change_scene_to_file("res://scenes/game/main_menu.tscn")

func _on_delete_slot(slot: int) -> void:
	if PlayerStats.delete_save(slot):
		_refresh_slots()

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game/main_menu.tscn")

func _on_hover() -> void:
	audio.stream = hover_sound
	audio.play()
