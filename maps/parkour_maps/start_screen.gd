extends Control


func show_start(jumps : int, level : int, nairs : int, gravity : float):
	$VboxContainer/levelText.text = "Level "+ str(level)
	$VboxContainer/jumps.text = "Max jumps: " + str(jumps)
	$VboxContainer/nairs.text = "Max nairs: " + str(nairs)
	$VboxContainer/Gravity.text = "Gravity: " + str(gravity)
	visible = true
	get_tree().paused = true
	await get_tree().create_timer(1.5).timeout
	get_tree().paused = false
	visible = false
