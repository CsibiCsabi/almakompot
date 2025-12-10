extends Control


@export var levelTile : PackedScene
var levels = 10
func _ready() -> void:
	for i in range(1,levels+1):
		var tile = levelTile.instantiate()
		tile.setName(str(i))
		$VBoxContainer/GridContainer.add_child(tile)
