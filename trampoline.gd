extends Area2D


@export var str = 750

func _on_body_entered(body: Node2D) -> void:
	body.trampoline(Vector2.UP.rotated(rotation) * str)
