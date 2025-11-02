extends Sprite2D




@export var player_id = 1

func _ready() -> void:
	Szorp.setp1Color(Color.WHITE)
	Szorp.setp2Color(Color.WHITE)

func _on_red_pressed() -> void:
	self_modulate = Color.RED
	if  player_id == 1:
		Szorp.setp1Color(Color.RED)
	else:
		Szorp.setp2Color(Color.RED)


func _on_blue_pressed() -> void:
	self_modulate = Color.DARK_BLUE
	if  player_id == 1:
		Szorp.setp1Color(Color.DARK_BLUE)
	else:
		Szorp.setp2Color(Color.DARK_BLUE)
		


func _on_green_pressed() -> void:
	self_modulate = Color.SEA_GREEN
	if  player_id == 1:
		Szorp.setp1Color(Color.SEA_GREEN)
	else:
		Szorp.setp2Color(Color.SEA_GREEN)
	


func _on_white_pressed() -> void:
	self_modulate = Color.WHITE
	if  player_id == 1:
		Szorp.setp1Color(Color.WHITE)
	else:
		Szorp.setp2Color(Color.WHITE)
