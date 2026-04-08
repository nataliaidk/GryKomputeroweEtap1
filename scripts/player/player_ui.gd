extends CanvasLayer

const WEAPONS_TEXTURE    := preload("res://assets/sprites/Weapons.png")
const WEAPONS_GRID_COLUMNS := 4
const WEAPONS_GRID_ROWS    := 5

var level_up_panel: PanelContainer
var level_up_title: Label
var level_up_buttons: Array[Button] = []
var level_label: Label
var exp_progress_bar: ProgressBar
var exp_label: Label

var _current_choices: Array[Dictionary] = []

@onready var player   = get_parent()
@onready var leveling = get_parent().get_node("PlayerLeveling")

func _ready():
	layer = 20
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	_build_ui()
	leveling.level_up_ready.connect(_on_level_up_ready)
	leveling.upgrade_applied.connect(_on_upgrade_applied)
	_refresh_exp_bar()

func _build_ui():
	# --- HUD (lewy górny róg) ---
	var hud := MarginContainer.new()
	hud.set_anchors_preset(Control.PRESET_TOP_LEFT)
	hud.offset_left = 16; hud.offset_top = 16
	hud.offset_right = 340; hud.offset_bottom = 140
	add_child(hud)

	var hud_box := VBoxContainer.new()
	hud_box.add_theme_constant_override("separation", 6)
	hud.add_child(hud_box)

	level_label = Label.new()
	hud_box.add_child(level_label)

	exp_progress_bar = ProgressBar.new()
	exp_progress_bar.min_value = 0
	exp_progress_bar.max_value = 1
	exp_progress_bar.custom_minimum_size = Vector2(260, 20)
	hud_box.add_child(exp_progress_bar)

	exp_label = Label.new()
	hud_box.add_child(exp_label)

	# --- Panel level-up (wyśrodkowany) ---
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	level_up_panel = PanelContainer.new()
	level_up_panel.custom_minimum_size = Vector2(780, 320)
	center.add_child(level_up_panel)

	var margin := MarginContainer.new()
	for side in ["top","bottom","left","right"]:
		margin.add_theme_constant_override("margin_" + side, 20 if side in ["top","bottom"] else 24)
	level_up_panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 16)
	margin.add_child(vbox)

	level_up_title = Label.new()
	level_up_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	level_up_title.text = "LEVEL UP"
	vbox.add_child(level_up_title)

	var subtitle := Label.new()
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.text = "Pick one item"
	vbox.add_child(subtitle)

	var choices_row := HBoxContainer.new()
	choices_row.add_theme_constant_override("separation", 12)
	vbox.add_child(choices_row)

	for i in range(3):
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(230, 190)
		btn.expand_icon = true
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		btn.pressed.connect(_on_choice_pressed.bind(i))
		choices_row.add_child(btn)
		level_up_buttons.append(btn)

	level_up_panel.visible = false

func _on_level_up_ready(choices: Array[Dictionary]):
	_current_choices = choices
	level_up_title.text = "LEVEL %d → %d" % [leveling.player_level, leveling.player_level + 1]
	for i in range(level_up_buttons.size()):
		var u := choices[i]
		level_up_buttons[i].text = "%s\n+%d DMG | +%d RANGE" % [
			u.get("name", "?"),
			int(u.get("damage_bonus", 0)),
			int(u.get("range_bonus", 0.0))
		]
		level_up_buttons[i].icon = _make_icon(u.get("icon_cell", Vector2i.ZERO))
	level_up_panel.visible = true
	get_tree().paused = true

func _on_choice_pressed(index: int):
	level_up_panel.visible = false
	get_tree().paused = false
	leveling.on_upgrade_chosen(index, _current_choices)
	_refresh_exp_bar()

func _on_upgrade_applied(_upgrade: Dictionary):
	_refresh_exp_bar()

func _refresh_exp_bar():
	var needed :int = leveling._required_blood(leveling.player_level + 1)
	level_label.text = "LVL %d" % leveling.player_level
	exp_progress_bar.max_value = needed
	exp_progress_bar.value = min(leveling.blood_exp, needed)
	exp_label.text = "EXP %d / %d" % [leveling.blood_exp, needed]

func _make_icon(icon_cell: Vector2i) -> Texture2D:
	var tex_size := WEAPONS_TEXTURE.get_size()
	var cell := Vector2(tex_size.x / float(WEAPONS_GRID_COLUMNS), tex_size.y / float(WEAPONS_GRID_ROWS))
	var clamped := Vector2i(
		clampi(icon_cell.x, 0, WEAPONS_GRID_COLUMNS - 1),
		clampi(icon_cell.y, 0, WEAPONS_GRID_ROWS - 1)
	)
	var icon := AtlasTexture.new()
	icon.atlas = WEAPONS_TEXTURE
	icon.region = Rect2(Vector2(clamped.x * cell.x, clamped.y * cell.y), cell)
	return icon
