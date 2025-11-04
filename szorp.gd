extends Node

var p1color : Color
var p2color : Color
var winnerText : String
var p1mutators : Array[Mutator] = []
var p2mutators : Array[Mutator] = []
var loser
func setp1Color(color):
	p1color = color
	print(p1color)
	
func setp2Color(color):
	p2color = color

func i_lost(_loser : int):
	loser = _loser
	winnerText = "Player "+( "1" if _loser == 2 else "2" )+ " won!"
	get_tree().change_scene_to_file("res://select_mutator.tscn")
