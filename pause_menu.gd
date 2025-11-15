extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

var paused = false
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		pause()

func pause():
	paused = not paused
	get_tree().paused = paused
	visible = paused

func _on_button_pressed() -> void:
	pause()


func _on_main_menu_pressed() -> void:
	pause()
	get_tree().change_scene_to_file("res://main_menu.tscn")
