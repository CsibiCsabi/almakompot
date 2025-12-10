extends Control

var level = 0
func setName(name : String):
	level = int(name)
	$Button.text = name


func _on_button_pressed() -> void:
	Szorp.level = level
	get_tree().change_scene_to_file("res://maps/parkour_maps/level_loader.tscn")
