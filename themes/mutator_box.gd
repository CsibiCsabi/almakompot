extends Control

var anim_player
var mutator : Mutator
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	anim_player = $AnimationPlayer

func setMutator(mut : Mutator):
	mutator = mut
	$Panel/VBoxContainer/name.text = mutator.name
	$Panel/VBoxContainer/stat.text = mutator.stat
	$Panel/VBoxContainer/desc.text = mutator.description

func _on_panel_mouse_entered() -> void:
	anim_player.play("grow")


func _on_panel_mouse_exited() -> void:
	anim_player.play("exit")
