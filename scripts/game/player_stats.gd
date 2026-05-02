extends Node
## Global player progression system - stores stats, gold, and unlocks

signal stats_changed
signal gold_changed

# Base stats
var max_health: int = 100
var damage: int = 10

# Resources
var gold: int = 200  # Starting gold

# Save slots
var save_slots: Array = []
# UI helpers
var show_secondary_on_open: bool = false

const SAVE_PATH = "user://bloodborn_saves/"
const SAVE_FILE = "save_{slot}.json"

func _ready() -> void:
	add_to_group("autoload")
	_ensure_save_directory()
	load_slot(0)  # Load first slot by default

# ── statystyki ────────────────────────────────────────────────────────────────

func upgrade_health(amount: int = 10) -> bool:
	if gold < amount:
		return false
	gold -= amount
	max_health += 10
	stats_changed.emit()
	gold_changed.emit()
	return true

func upgrade_damage(amount: int = 5) -> bool:
	if gold < amount:
		return false
	gold -= amount
	damage += 5
	stats_changed.emit()
	gold_changed.emit()
	return true

func add_gold(amount: int) -> void:
	gold += amount
	gold_changed.emit()

# ── zapis / załadowanie ───────────────────────────────────────────────────────

func _ensure_save_directory() -> void:
	if not DirAccess.dir_exists_absolute(SAVE_PATH):
		DirAccess.make_dir_absolute(SAVE_PATH)

func _get_save_file_path(slot: int) -> String:
	return SAVE_PATH + SAVE_FILE.format({"slot": slot})

func save_slot(slot: int) -> bool:
	if not (0 <= slot and slot < 3):
		return false
	
	var save_data = {
		"max_health": max_health,
		"damage": damage,
		"gold": gold,
		"timestamp": Time.get_ticks_msec()
	}
	
	var file_path = _get_save_file_path(slot)
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	
	if file == null:
		printerr("Failed to save to slot %d" % slot)
		return false
	
	file.store_var(save_data)
	print("Saved to slot %d" % slot)
	return true

func load_slot(slot: int) -> bool:
	if not (0 <= slot and slot < 3):
		return false
	
	var file_path = _get_save_file_path(slot)
	
	if not FileAccess.file_exists(file_path):
		# First time - use defaults
		print("No save in slot %d, using defaults" % slot)
		return true
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		printerr("Failed to load slot %d" % slot)
		return false
	
	var save_data = file.get_var()
	max_health = save_data.get("max_health", 100)
	damage = save_data.get("damage", 10)
	gold = save_data.get("gold", 200)
	
	stats_changed.emit()
	gold_changed.emit()
	print("Loaded from slot %d" % slot)
	return true

func get_save_info(slot: int) -> Dictionary:
	if not (0 <= slot and slot < 3):
		return {}
	
	var file_path = _get_save_file_path(slot)
	
	if not FileAccess.file_exists(file_path):
		return {
			"slot": slot,
			"exists": false,
			"health": 0,
			"damage": 0,
			"gold": 0
		}
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		return {}
	
	var save_data = file.get_var()
	return {
		"slot": slot,
		"exists": true,
		"health": save_data.get("max_health", 100),
		"damage": save_data.get("damage", 10),
		"gold": save_data.get("gold", 200),
		"timestamp": save_data.get("timestamp", 0)
	}

func delete_save(slot: int) -> bool:
	if not (0 <= slot and slot < 3):
		return false

	var file_path := _get_save_file_path(slot)
	if not FileAccess.file_exists(file_path):
		return true

	var dir := DirAccess.open(SAVE_PATH)
	if dir == null:
		return false

	var err := dir.remove(SAVE_FILE.format({"slot": slot}))
	if err != OK:
		printerr("Failed to delete save slot %d" % slot)
		return false

	print("Deleted save slot %d" % slot)
	return true

func reset_to_defaults() -> void:
	max_health = 100
	damage = 10
	gold = 200
	stats_changed.emit()
	gold_changed.emit()
