extends Resource

class_name Mutator

@export var name : String
@export var description : String
@export var stat : String
var on_apply : Callable = func(player): pass

func apply_to_player(player):
	if on_apply != null:
		on_apply.call(player)

func _init(_name : String, _stat : String, _description : String, _on_apply : Callable) -> void:
	name = _name
	stat  = _stat
	description = _description
	on_apply = _on_apply
	
