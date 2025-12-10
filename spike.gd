extends Area2D



func _on_body_entered(body: Node2D) -> void:
	body.jumpCount = 0
	body.nairCount = 0
	body.spike_hit()
