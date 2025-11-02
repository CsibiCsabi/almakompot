extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

@onready var preview1 = $preview1
func _ready() -> void:
	
func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://platform.tscn")


func _on_blue_pressed() -> void:
	pass # Replace with function body.


func _on_green_pressed() -> void:
	pass # Replace with function body.


func _on_white_pressed() -> void:
	pass # Replace with function body.
