extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if Szorp.chosen_gamemode == Szorp.Gamemode.parkour:
		body.restart()
	else:
		body.die()
