extends Node2D


@onready var p1 = $p1
@onready var p2 = $p2



func _ready() -> void:
	select_random_map()


		

func select_random_map():
	var map = Szorp.map_paths.pick_random()
	var scene = load(map).instantiate()
	$MapContainer.add_child(scene)
	var p1pos = scene.get_node("player1position").global_position 
	var p2pos = scene.get_node("player2position").global_position 
	p1.global_position = p1pos
	p2.global_position = p2pos
	return
