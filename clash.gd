extends Area2D


func _ready() -> void:
	self.area_entered.connect(Callable(self, "_clash"))

func _clash(area : Area2D):
	get_parent().get_parent().clash()
