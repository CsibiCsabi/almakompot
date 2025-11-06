extends Control


@onready var card_container = $CanvasLayer/CenterContainer/HBoxContainer
@export var mutator_card_scene: PackedScene

func _ready() -> void:
	$MarginContainer/VBoxContainer/player.text = "Player " + str(Szorp.loser) + "'s choice!"
	show_random_mutators(0)

func show_random_mutators(count : int):
	var keys = Mutator_Library.all_mutators.keys()
	for i in range(min(keys.size(), count)):
		var mutator = Mutator_Library.all_mutators[keys.pick_random()]
		var card = mutator_card_scene.instantiate()
		card.mutator = mutator
		card.connect("mutator_selected", Callable(self, "_on_mutator_selected"))
		card_container.add_child(card)

func _on_mutator_selected(mutator : Mutator):
	print("kiválasztott mutator:")
	#Szorp.p1mutators.append(mutator)
	#get_tree().change_scene_to_file("res://platform.tscn")
