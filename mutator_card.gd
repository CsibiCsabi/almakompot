extends Control


var mutator : Mutator

func _ready() -> void:
	var selected = Mutator_Library.all_mutators.keys().pick_random()
	mutator = Mutator_Library.all_mutators[selected]
	$VBoxContainer/name.text = mutator.name
	$VBoxContainer/stat.text = mutator.stat
	$VBoxContainer/desc.text = mutator.description
	

func _on_select_pressed() -> void:
	print("asd")
	if Szorp.loser == 1:
		Szorp.p1mutators.append(mutator)
	else:
		Szorp.p2mutators.append(mutator)
	get_tree().change_scene_to_file("res://platform.tscn")
