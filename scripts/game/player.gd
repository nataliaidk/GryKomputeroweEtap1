extends CharacterBody2D

signal exp_gained(amount: int)

@onready var save_manager := SaveManager
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var camera := $Camera2D
@onready var health_bar: TextureProgressBar = $TextureProgressBar
@onready var weapon_manager: WeaponManager = $WeaponManager
@onready var audio = $AudioStreamPlayer
@onready var timer: Timer = $HealTimer

@export var die_sound: AudioStream
@export var hurt_sounds: Array[AudioStream]

var speed := 200.0
var max_health := 100
var health := max_health
var is_dead := false
var facing_direction := Vector2.DOWN
var facing_direction_x := 1
var is_attacking := false
var hp_regen := 1
var luck := 0
var _gold_per_second := 1

func _ready():
	camera.make_current()
	
	var h = SaveManager.selected_hero
	var i = SaveManager.selected_hero_index
	max_health = SaveManager.get_stat(i, "max_health", h.max_health)
	speed = SaveManager.get_stat(i, "speed", h.speed)
	luck = SaveManager.get_stat(i, "luck", h.luck)
	sprite.sprite_frames = h.sprite_frames
	
	health = max_health
	health_bar.value = health
	health_bar.max_value = max_health
	
	var whip_data = load("res://data/weapons/whip_data.tres")
	weapon_manager.add_weapon(whip_data)
	GameTimer.start()
	
func _physics_process(_delta):
	if is_dead:
		return
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction != Vector2.ZERO:
		facing_direction = direction.normalized()
		calculate_facing_direction_x()
	velocity = Vector2.ZERO if is_attacking else direction * speed
	move_and_slide()
	update_animation(direction if not is_attacking else Vector2.ZERO)

func calculate_facing_direction_x():
	if facing_direction.x != 0:
		if facing_direction.x < 0:
			facing_direction_x = -1
		if facing_direction.x > 0:
			facing_direction_x = 1

func update_animation(direction: Vector2):
	if is_attacking or direction == Vector2.ZERO:
		sprite.play("idle")
		return
	if abs(direction.x) > abs(direction.y):
		sprite.play("walk_right" if direction.x > 0 else "walk_left")
	else:
		sprite.play("walk_down" if direction.y > 0 else "walk_up")

func take_damage(attack: Attack):
	if is_dead:
		return
	health -= attack.damage
	health_bar.value = health
	flash_red()
	if health <= 0:
		die()
	else:
		audio.stream = hurt_sounds.pick_random()
		audio.play()

func flash_red():
	sprite.modulate = Color(1, 0.3, 0.3)
	await get_tree().create_timer(0.2).timeout
	sprite.modulate = Color(1, 1, 1) 

func die():
	GameTimer.stop()
	audio.stream = die_sound
	audio.play()
	is_dead = true
	is_attacking = false
	velocity = Vector2.ZERO
	weapon_manager.disable_all()
	sprite.play("die")
	await sprite.animation_finished
	get_tree().change_scene_to_file("res://scenes/ui/death_screen.tscn")

func add_kill():
	$PlayerHud.add_kill()

func gain_xp(amount: int):
	if is_dead or amount <= 0:
		return
	exp_gained.emit(amount)

func apply_bonus(bonus: ItemLevelData) -> void:
	hp_regen = 1 + bonus.hp_regen

func _on_heal_timer_timeout() -> void:
	health = min(max_health, health + hp_regen)
	health_bar.value = health
