extends Control

@onready var text = $VBoxContainer/roundText

func _ready() -> void:
	var str = "Player " + ("1" if Szorp.loser == 2 else "2") + "won this round"
	text.text = str




func _on_next_round_pressed() -> void:
	Szorp.next_round()
