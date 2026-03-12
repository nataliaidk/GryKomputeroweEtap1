extends CharacterBody2D

const SPEED = 100.0
var player = null
var hp = 20 

func _ready():
	player = get_tree().get_first_node_in_group("player")

func _physics_process(_delta):
	if player:
		var direction = global_position.direction_to(player.global_position)
		velocity = direction * SPEED
		move_and_slide()

func take_damage(amount):
	hp -= amount 
	$ProgressBar.value = hp
	if hp <= 0:
		die()

func die():
	queue_free()
