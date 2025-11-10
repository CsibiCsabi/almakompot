extends Control


var mutator : Mutator
var animPlayer
var selectable = true

signal mutator_selected(mut : Mutator)

func _ready() -> void:
	
	animPlayer = $AnimationPlayer

func setMutator(mut : Mutator):
	mutator = mut
	$Panel/VBoxContainer/name.text = mutator.name
	$Panel/VBoxContainer/stat.text = mutator.stat
	$Panel/VBoxContainer/desc.text = mutator.description


func _on_select_pressed() -> void:
	$Panel/VBoxContainer/select.disabled = true
	$Panel.modulate = Color.DIM_GRAY
	selectable = false
	$Panel.scale = Vector2(1,1)
	emit_signal("mutator_selected", mutator)


func _on_panel_mouse_entered() -> void:
	if selectable:
		animPlayer.play("hover")
		var sb = $Panel.get_theme_stylebox("panel").duplicate()
		sb.shadow_size = 10
		$Panel.add_theme_stylebox_override("panel", sb)


func _on_panel_mouse_exited() -> void:
	if selectable:
		animPlayer.play("exit")
		var sb = $Panel.get_theme_stylebox("panel").duplicate()
		sb.shadow_size = 5
		$Panel.add_theme_stylebox_override("panel", sb)
