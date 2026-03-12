extends Node2D

@export var enemy_scene: PackedScene 

func _on_timer_timeout():
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return
		
	if not enemy_scene:
		return
		
	var enemy = enemy_scene.instantiate()
	
	var spawn_radius = 600.0
	var random_angle = randf() * PI * 2
	var spawn_offset = Vector2(cos(random_angle), sin(random_angle)) * spawn_radius
	
	enemy.global_position = player.global_position + spawn_offset
	add_child(enemy)
