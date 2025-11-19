extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.





func _on_button_pressed() -> void:
	Szorp.setGamemode(Szorp.Gamemode.classic)
	get_tree().change_scene_to_file("res://choose_character.tscn")


func _on_infected_pressed() -> void:
	Szorp.setGamemode(Szorp.Gamemode.infected)
	get_tree().change_scene_to_file("res://choose_character.tscn")


func _on_draft_pressed() -> void:
	Szorp.setGamemode(Szorp.Gamemode.draft)
	get_tree().change_scene_to_file("res://choose_character.tscn")


func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://settings.tscn")
	return
	


func _on_custom_pressed() -> void:
	Szorp.setGamemode(Szorp.Gamemode.custom)
	get_tree().change_scene_to_file("res://custom.tscn")
