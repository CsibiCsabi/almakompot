extends Node

var p1color : Color
var p2color : Color
var winnerText : String
var p1mutators : Array[Mutator] = []
var p2mutators : Array[Mutator] = []
var loser = 1
var p1points = 0
var p2points = 0

#COLLISION LAYERS: 
#1 - p1 
#2 - p2
#3 - floor
#4 - one-way floor

#map valasztashoz
var map_paths = [
	"res://maps/map1.tscn",
	"res://maps/map2.tscn",
	"res://maps/map3.tscn"
]


#mutatorhoz
enum Rarity {common, uncommon, rare}
enum Gamemode {classic, draft, infected}
var chosen_gamemode : Gamemode

func newGame():
	p1points = 0
	p2points = 0
	p1mutators = []
	p2mutators = []
	match chosen_gamemode:
		Gamemode.classic:
			get_tree().change_scene_to_file("res://platform.tscn")
		Gamemode.draft:
			get_tree().change_scene_to_file("res://draft_scene.tscn")


func setGamemode(mode : Gamemode):
	chosen_gamemode = mode

func setp1Color(color):
	p1color = color
	
func setp2Color(color):
	p2color = color

func i_lost(_loser : int):
	loser = _loser
	if loser == 1:
		p2points+=1
	else:
		p1points += 1
	winnerText = "Player "+( "1" if _loser == 2 else "2" )+ " won!"
	if p1points >= 4 or p2points >= 4:
		get_tree().change_scene_to_file("res://end_screen.tscn")
		return
	get_tree().change_scene_to_file("res://select_mutator.tscn")

func next_round():
	get_tree().change_scene_to_file("res://platform.tscn")
