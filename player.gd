extends CharacterBody2D

const SPEED = 200.0

func _physics_process(_delta):
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	velocity = direction * SPEED
	move_and_slide()


func _on_attack_timer_timeout():
	var bodies_in_range = $AttackAura.get_overlapping_bodies()
	for body in bodies_in_range:
		if body.has_method("take_damage"):
			body.take_damage(5)
