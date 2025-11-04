extends Node

class_name MutatorLibrary
var all_mutators : Dictionary = {}

func _ready() -> void:
	add_built_in_mutators()

func add_built_in_mutators():
	#strength
	var mutator = Mutator.new("strength", "more strength", "Who's a big boy?", func(player):
			player.strength += 10
			)
	all_mutators[mutator.name] = mutator
	#agility
	mutator = Mutator.new("speedy boy", "more speed\nmore jump force",  "get out of my way!", func(player):
			player.speed += 40
			player.jump_force -= 40
			)
	all_mutators[mutator.name] = mutator
	#stun
	mutator = Mutator.new("Shocking looks", "more stun", "You look stunning!", func(player):
			player.plusStun += 0.1
			)
	all_mutators[mutator.name] = mutator
	#def
	mutator = Mutator.new("Buff guy", "a lot more defense\nless speed", "Good luck knocking me out...", func(player):
			player.speed -= 70
			player.defense += 10
			)
	all_mutators[mutator.name] = mutator
	#dodge
	mutator = Mutator.new("Antisocial", "lower dash cooldown\nmore speed", "No! I don't want to talk!", func(player):
			player.dashCooldown -= 0.15
			player.speed += 40
			)
	all_mutators[mutator.name] = mutator
	#punish
	mutator = Mutator.new("Careless", "shorter punish after missing an attack", "I missed? I don't care...", func(player):
			player.missPunish -= 0.05
			)
	all_mutators[mutator.name] = mutator
	#gravity
	mutator = Mutator.new("Out of this world", "Lower gravity", "I'm so high!", func(player):
			player.gravityMultiplier -= 0.1
			print(player.gravityMultiplier)
			)
	all_mutators[mutator.name] = mutator
	
	
	
	
	
