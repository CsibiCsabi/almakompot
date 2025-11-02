extends Node

var p1color : Color
var p2color : Color
var winnerText : String

func setp1Color(color):
	p1color = color
	print(p1color)
	
func setp2Color(color):
	p2color = color

func i_lost(loser : int):
	winnerText = "Player "+( "1" if loser == 2 else "2" )+ " won!"
	get_tree().change_scene_to_file("res://end_screen.tscn")
