extends Area2D

signal level_completed


func _on_body_entered(body: Node2D) -> void:
	emit_signal("level_completed")
	print("completed!!!!")
