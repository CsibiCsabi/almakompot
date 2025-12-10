extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$text.text = $/root/Szorp.winnerText
	


func _on_restart_pressed() -> void:
	Szorp.newGame()



func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://UI/main_menu.tscn")
