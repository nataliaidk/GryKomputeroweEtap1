class_name BaseEnemy
extends CharacterBody2D

signal died

@onready var player: Node2D = get_tree().get_first_node_in_group("player")
@export var blood_exp_reward := 1
const DAMAGE_FONT: FontFile = preload("res://assets/fonts/Gothikka.ttf")
const BLOOD_TEXTURE: Texture2D = preload("res://assets/blood/1_100x100px.png")

var speed := 100.0
var max_health := 100
var health := max_health
var damage := 10
var blood_lifetime := 0.4
var is_dead := false
var _player_in_range: Node2D = null

# Knockback
var knockback_velocity := Vector2.ZERO
var knockback_duration := 0.0
var knockback_speed := 300.0

var xp_gem_table: Array = [
	[XpGem.Type.NONE,   40],
	[XpGem.Type.SMALL,  60],
	[XpGem.Type.MEDIUM,  0],
	[XpGem.Type.LARGE,   0],
]

# ── lifecycle ────────────────────────────────────────────────────────────────

func _ready() -> void:
	health = max_health
	_setup_visuals()

func _physics_process(_delta: float) -> void:
	if is_dead or player == null:
		return
	
	# Handle knockback
	if knockback_duration > 0:
		knockback_duration -= _delta
		# Knockback only affects horizontal movement
		velocity.x = knockback_velocity.x
		var dir := global_position.direction_to(player.global_position)
		velocity.y = dir.y * speed
	else:
		var dir := global_position.direction_to(player.global_position)
		velocity = dir * speed
	
	move_and_slide()
	_update_animation(velocity.normalized())

# ── wirtualne metody  ────────────────────────────────────────────────────────

func _setup_visuals() -> void:
	pass

func _update_animation(_dir: Vector2) -> void:
	pass

func flash_red() -> void:
	pass

# ── walka ────────────────────────────────────────────────────────────────────

func take_damage(attack: Attack) -> void:
	if is_dead:
		return
	_show_damage_number(attack.damage)
	health -= attack.damage
	_spawn_blood(blood_lifetime * 0.8, 16.0)
	flash_red()
	
	# Apply knockback
	var knockback_dir := global_position.direction_to(attack.position).normalized()
	knockback_velocity = knockback_dir * knockback_speed
	knockback_duration = 0.2
	
	if health <= 0:
		die()

func die() -> void:
	if is_dead:
		return
	is_dead = true
	if is_instance_valid(player) and player.has_method("gain_blood_exp"):
		player.gain_blood_exp(blood_exp_reward)
	velocity = Vector2.ZERO
	$HurtboxArea.monitoring = false
	$Collision.set_deferred("disabled", true)
	$DamageTimer.stop()
	player.add_kill()
	_spawn_blood(blood_lifetime * 1.3, 35.0)
	_spawn_blood_decal()
	_drop_xp_gems()
	queue_free()

func attack() -> void:
	if _player_in_range == null or not is_instance_valid(_player_in_range):
		return
	var atk := Attack.new()
	atk.damage   = damage
	atk.position = global_position
	_player_in_range.get_parent().take_damage(atk)

# ── upuszczanie gemów XP ─────────────────────────────────────────────────────

func _drop_xp_gems() -> void:
	var gem_type := _roll_gem_type()
	if gem_type == XpGem.Type.NONE:
		return
	_spawn_gem(gem_type)

func _roll_gem_type() -> XpGem.Type:
	var total_weight := 0
	for entry in xp_gem_table:
		total_weight += entry[1]

	var roll := randi_range(0, total_weight - 1)
	var cumulative := 0
	for entry in xp_gem_table:
		cumulative += entry[1]
		if roll < cumulative:
			return entry[0]

	return xp_gem_table[0][0]

func _spawn_gem(gem_type: XpGem.Type) -> void:
	var gem := XpGem.new()
	gem.gem_type = gem_type
	gem.global_position = global_position
	get_parent().add_child(gem)

# ── sygnały hitboxa / timera ─────────────────────────────────────────────────

func _on_hitbox_area_entered(area: Area2D) -> void:
	if is_dead or not area.is_in_group("player"):
		return
	_player_in_range = area
	attack()
	$DamageTimer.start()

func _on_hitbox_area_exited(area: Area2D) -> void:
	if area == _player_in_range:
		_player_in_range = null
		$DamageTimer.stop()

func _on_damage_timer_timeout() -> void:
	if _player_in_range and not is_dead:
		attack()

# ── krew ─────────────────────────────────────────────────────────────────────

func _spawn_blood(lifetime: float, vel_min: float) -> void:
	var p := CPUParticles2D.new()
	p.amount               = 18
	p.one_shot             = true
	p.lifetime             = max(0.05, lifetime)
	p.spread               = 55.0
	p.initial_velocity_min = vel_min
	p.initial_velocity_max = vel_min + 36.0
	p.gravity              = Vector2(0, 75)
	p.scale_amount_min     = 0.9
	p.scale_amount_max     = 1.8
	p.color                = Color(0.73, 0.05, 0.08, 0.85)
	p.local_coords         = false
	p.z_index              = 20
	p.global_position      = global_position
	get_parent().add_child(p)
	p.emitting = true
	await get_tree().create_timer(p.lifetime + 0.3).timeout
	if is_instance_valid(p):
		p.queue_free()

func _spawn_blood_decal() -> void:
	var decal := Node2D.new()
	decal.global_position = global_position
	decal.rotation = randf_range(0, TAU)
	
	var sprite := Sprite2D.new()
	sprite.centered = true
	
	# Create AtlasTexture to extract the 2nd row, 1st column from the sprite sheet
	var atlas := AtlasTexture.new()
	atlas.atlas = BLOOD_TEXTURE
	atlas.region = Rect2(0, 100, 100, 100)  # 2nd row, 1st column
	
	sprite.texture = atlas
	sprite.scale = Vector2.ONE * randf_range(0.7, 1.2)
	sprite.z_index = 5
	sprite.modulate.a = 0.8
	
	decal.add_child(sprite)
	get_parent().add_child(decal)

func _show_damage_number(amount: int) -> void:
	if amount <= 0:
		return
	var label := Label.new()
	label.text = str(amount)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_override("font", DAMAGE_FONT)
	label.add_theme_font_size_override("font_size", 28)
	label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))
	label.add_theme_color_override("font_outline_color", Color(0.32, 0.0, 0.0, 1.0))
	label.add_theme_constant_override("outline_size", 4)
	label.top_level = true
	label.z_index = 35
	label.global_position = global_position + Vector2(randf_range(-12.0, 12.0), -18.0)
	get_tree().current_scene.add_child(label)

	var tween := label.create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(label, "global_position", label.global_position + Vector2(0, -42), 0.55)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 1.0)
	await tween.finished
	if is_instance_valid(label):
		label.queue_free()
