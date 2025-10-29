extends CharacterBody2D

var hp = 200


func hit()->void:
	hp-= 10
	print(hp)
	return
