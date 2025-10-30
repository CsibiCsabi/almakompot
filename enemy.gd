extends CharacterBody2D

var hp = 200


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	velocity.x = move_toward(velocity.x, 0, 40)
	move_and_slide()

func hit(dmg: int, force: Vector2)->void:
	velocity = force
	hp-= dmg
	return
