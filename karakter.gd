extends CharacterBody2D

func _ready() -> void:
	change_state(PlayerState.Idle, "idle")
	add_to_group("player"+str(player_id))
	inputBuffers = {
	("p"+str(player_id)+"attack") : 0.0,
	("p"+str(player_id)+"dash") : 0.0,
	("p"+str(player_id)+"jump") : 0.0,
	("p"+str(player_id)+"heavy") : 0.0
	}
	#controllers
	var controllers = Input.get_connected_joypads()
	print(controllers)
	if controllers.size() >= player_id:
		controller_id = controllers[player_id-1] 
		usingController = true
		print("lett connectelve")
	inputs = {
		"attack" : JOY_BUTTON_X,
		"jump" : JOY_BUTTON_A,
		"dash" : JOY_BUTTON_B
		}
	
	if player_id == 1:
		print("p1 mutators:")
		color = Szorp.p1color
		apply_mutators(Szorp.p1mutators)
	else:
		print("p2 mutators:")
		color = Szorp.p2color
		apply_mutators(Szorp.p2mutators)
	sprite.self_modulate = color
	attacks = {
		"sword_neutral" : AttackData.new("sword_neutral", 1.4, Vector2(300,-200), 0.3),
		
		"sword_side" : AttackData.new("sword_side", 1,Vector2(400,-100), 0.2),
		"sword_down" : AttackData.new("sword_down", 0.8,Vector2(200,-240), 0.5),
		"sword_nair" : AttackData.new("sword_nair", 1,Vector2(200,-250), 0.3),
		"sword_dair" : AttackData.new("sword_dair", 1.2,Vector2(10,100), 0.15),
		"clash" : AttackData.new("clash", 0,Vector2(400,-200), 0.2),
		"sword_heavy_neutral1" : AttackData.new("sword_heavy_neutral1", 1, Vector2(100,-330), 0.5),
		"sword_heavy_neutral2" : AttackData.new("sword_heavy_neutral2", 1, Vector2(400,0), 0.3),
		"sword_heavy_side1" : AttackData.new("sword_heavy_side1", 1, Vector2(0,-100), 0.3),
		"sword_heavy_side2" : AttackData.new("sword_heavy_side2", 1, Vector2(350,50), 0.5),
		"sword_heavy_down1" : AttackData.new("sword_heavy_down1", 1, Vector2(500,-100), 0.5),
		"sword_heavy_down2" : AttackData.new("sword_heavy_down2", 1, Vector2(-500,-100), 0.5),
	}


var hp : float = 0
@export var mutator_box_scene: PackedScene
class AttackData:
	var name : String
	var dmg: float
	var force: Vector2
	var stunTime : float

	func _init(_name, _damage, _force, _stunTime):
		name = _name
		dmg = _damage
		force = _force
		stunTime = _stunTime

#state
enum PlayerState {Idle, Run, Attack, Jump, Dash, Hurt}
var currentState: PlayerState;
var plusStun = 0.0
var color
@export var player_id = 1
@onready var label = $CanvasLayer/Label
@onready var anim_player = $AnimationPlayer
@onready var sprite = $Sprite2D
var attacks = {}
var speed = 400
var canMove = true

var myColor
var facingLeft
var hurtable = true
#jumpi
var jump_force = -300.0
var maxJumps = 2
var jumpCount = 0

#conti
var inputs = {}
var usingController = false
var controller_id = -1
var contiDeadzone = 0.3

#dash
var canDash = true
var horizontalDashForce = 600
var verticalDashForce = 300
var dashCooldown = 0.8
var horizontal
var vertical
# weaponing
var weapon = "sword"
var attackType
var canAttack = true;
var hitSomething = false
var attackCooldown = 0.2
var missPunish = 0.2
var attack_buffer = 0
var input_buffer_time = 0.2
var justJumped = false
var inputBuffers = {}
var nairCount = 0
var maxNairs = 2
var noMultiplierAttacks = ["sword_down", "sword_heavy_neutral1"]
var stunExceptionAttacks = ["sword_down", "sword_dair"]
var strength : float = 10
var defense : float = 100

var noAttackAnims = ["run", "idle", "hurt", "jump", "dash"]

#stun/beung hurt
var stunned = false
var currentForce = Vector2(0,0)
var stunTimer = 0

#for mutators
var gravityMultiplier = 1.0
var dashVertical
var dashHorizontal
#dash mutators
var pushDodge = 0 # 400-600
var attackDodge = 0.0 # multiplier 0-2
var stunDodge = 0.0 # time 0.1-0.4
#poison
var poison = 0 # the poison you apply
var poison_length = 5 # times of dmg
var poisonsToBeAdded = 0
var poisonDamage = 0 #the poison you take as dmg
var canApplyPoison = true
#stinger
var stinger = 0
var stingTimer = -0.1
var stingCooldown = 5

#one_way thingy
var down_time = 0.06 # how long to go down a one way coll
var one_way_timer = 0
var one_way_time = 0.1

#trampoline
var knock_back_time = 0.2
var knock_back_timer = 0
var trampoline_force = Vector2(0,0)

var down = false # fast fallhoz

func apply_mutators(mutators):
	for mutator in mutators:
		print(mutator.name)
		mutator.on_apply.call(self)
		var box = mutator_box_scene.instantiate()
		box.setMutator(mutator)
		if mutator.rarity == Szorp.Rarity.common:
			print(mutator.name + ": common")
			box.theme = preload("res://themes/common_theme.tres")
		elif mutator.rarity == Szorp.Rarity.uncommon:
			box.theme = preload("res://themes/uncommon_theme.tres")
			print(mutator.name + ": uncommon")
		elif mutator.rarity == Szorp.Rarity.rare:
			box.theme = preload("res://themes/rare_theme.tres")
			print(mutator.name + ": rare")
		$CanvasLayer/Mutators.add_child(box)
	return

func _input(event):
	if usingController:
		var jump = Input.is_joy_button_pressed(controller_id, inputs["jump"])
		if Input.is_joy_button_pressed(controller_id, inputs["attack"]):
			inputBuffers["p"+str(player_id)+"attack"] = input_buffer_time
		if jump and not justJumped:
			inputBuffers["p"+str(player_id)+"jump"] = input_buffer_time
		if Input.is_joy_button_pressed(controller_id, inputs["dash"]):
			inputBuffers["p"+str(player_id)+"dash"] = input_buffer_time
		justJumped = jump
		#TODO: ONE WAY COLLISION
		
		
		
		
	else:
		for i in inputBuffers.keys():
			if event.is_action_pressed(i):
				inputBuffers[i] = input_buffer_time
		if Input.is_action_just_pressed("p"+str(player_id)+"down"):
			await get_tree().create_timer(down_time).timeout
			if currentState == PlayerState.Idle or currentState == PlayerState.Run or currentState == PlayerState.Jump: 
				collision_mask &= ~(1 << 3)
			else:
				collision_mask |= (1 << 3)
				
		if Input.is_action_just_released("p"+str(player_id)+"down"):
			collision_mask |= (1 << 3)
			await get_tree().create_timer(down_time).timeout
			collision_mask |= (1 << 3)


func apply_poison(dmg : float):
	poisonsToBeAdded -=1
	canApplyPoison = false
	hp += dmg
	sprite.self_modulate = Color.GREEN
	await get_tree().create_timer(0.3).timeout
	sprite.self_modulate = color
	await get_tree().create_timer(0.2).timeout
	canApplyPoison = true
	label.text = "PLAYER"+str(player_id)+" HP: "+str(hp)
	return

func _physics_process(delta: float) -> void:
	if one_way_timer >= 0:
		one_way_timer -= delta
		if one_way_timer < 0:
			collision_mask |= (1 << 3)
	if poisonsToBeAdded > 0 and canApplyPoison:
		apply_poison(poisonDamage)
	if stingTimer > 0:
		stingTimer-= delta
	if stunned:
		velocity.x = move_toward(velocity.x, 0, 1000 * delta)
		velocity += get_gravity() * delta * gravityMultiplier
		stunTimer -= delta
		if stunTimer < 0:
			knock_back_timer = 0
			stunned = false
			canMove = true
			canAttack = true
			hitSomething = false
			facingLeft = !facingLeft
			sprite.scale.x = -1 if facingLeft else 1
			if abs(velocity.x) > 0.3 and usingController:
				change_state(PlayerState.Run, "run")
			elif abs(velocity.x) > 0 and not usingController:
				change_state(PlayerState.Run, "run")
			else:
				change_state(PlayerState.Idle, "idle")
		

	else: #no stun
		for key in inputBuffers.keys():
			if inputBuffers[key] > 0:
				inputBuffers[key] -= delta
		
		# Add the gravity.
		if not is_on_floor() and currentState != PlayerState.Dash:
			if usingController:
				if Input.get_joy_axis(controller_id, JOY_AXIS_LEFT_Y) < (-1)*contiDeadzone:
					down = true
				else:
					down = false
			else:
				if Input.is_action_pressed("p"+str(player_id)+"down"):
					down = true
				else:
					down = false
			velocity += get_gravity() * delta * gravityMultiplier * (2 if down else 1)
			print("fastfall" if down else "no")
			
			
	
		if is_on_floor():
			jumpCount = 0
			nairCount = 0
		# Handle jump.
		if inputBuffers["p"+str(player_id)+"jump"] > 0 and jumpCount < maxJumps and currentState != PlayerState.Attack:
			inputBuffers["p"+str(player_id)+"jump"] = 0
			velocity.y = jump_force
			jumpCount+=1
		#movement
		var direction = 0
		if usingController:
			direction = Input.get_joy_axis(controller_id, JOY_AXIS_LEFT_X)
		else:
			direction = Input.get_axis("p"+str(player_id)+"left", "p"+str(player_id)+"right")
		if canDash and inputBuffers["p"+str(player_id)+"dash"] > 0 and currentState != PlayerState.Dash and currentState != PlayerState.Attack:
			inputBuffers["p"+str(player_id)+"dash"] = 0
			knock_back_timer = 0
			dash()
			return
		if (direction > contiDeadzone or direction < (-1*contiDeadzone)) and canMove:
			sprite.scale.x = -1 if direction < 0 else 1
			facingLeft = direction <= 0
			velocity.x = direction * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
		
		if knock_back_timer > 0:
			print("now")
			knock_back_timer -= delta
			velocity = trampoline_force
		
		#State Update
		update_state(direction)
	move_and_slide()

func allHurtboxesOff():
	$Sprite2D/sword_neutral/sword_neutral.disabled = true
	$Sprite2D/sword_side/sword_side.disabled = true
	$Sprite2D/sword_down/sword_down.disabled = true
	$"Sprite2D/sword_down/1".disabled = true
	$"Sprite2D/sword_down/2".disabled = true
	$"Sprite2D/sword_nair/1".disabled = true
	$"Sprite2D/sword_nair/2".disabled = true
	$"Sprite2D/sword_nair/3".disabled = true
	$"Sprite2D/sword_dair/1".disabled = true
	$"Sprite2D/sword_heavy_neutral/1".disabled = true
	$"Sprite2D/sword_heavy_neutral/2".disabled = true
	$"Sprite2D/sword_heavy_side/1".disabled = true
	$"Sprite2D/sword_heavy_side/2".disabled = true
	$"Sprite2D/sword_heavy_side/finish1".disabled = true
	$"Sprite2D/sword_heavy_side/finish2".disabled = true
	$Sprite2D/dodge/dodge.disabled = true
	$"Sprite2D/sword_heavy_down/1".disabled = true
	$"Sprite2D/sword_heavy_down/2".disabled = true


func die():
	Szorp.i_lost(player_id)
	queue_free()

func hit(data : AttackData, str : int, poison : float, stinger : int)->void:
	allHurtboxesOff()
	print(data.name)
	if not hurtable:
		return
	else:
		#stun mechanic
		stunned = true
		collision_mask &= ~(1 << 3)
		one_way_timer = one_way_time
		sprite.scale.x = 1 if data.force.x > 0 else -1
		facingLeft = data.force.x < 0
		change_state(PlayerState.Hurt, "hurt")
		if data.name in noMultiplierAttacks:
			velocity = data.force
		else:
			var forceX = data.force.x * (1 + hp / defense)
			var forceY = data.force.y * (1 + hp / (defense*2))
			velocity = Vector2(forceX, forceY)
		if data.name in stunExceptionAttacks:
			stunTimer = data.stunTime
		else:
			stunTimer = data.stunTime * (1 + hp / (defense*2))

		hp += data.dmg * str / (defense / 100)
		label.text = "PLAYER"+str(player_id)+" HP: "+str(hp)
		if poison != 0:
			poisonsToBeAdded = 4
			poisonDamage = poison
		if stinger != 0 and stingTimer < 0:
			sting(stinger)
		return

func sting(number : int):
	await get_tree().create_timer(stunTimer).timeout
	stingTimer = stingCooldown
	for i in range(number):
		await get_tree().create_timer(1).timeout
		stunned = true
		change_state(PlayerState.Hurt, "hurt")
		velocity.x = 0
		stunTimer = 0.3



func hit_opponent(body : Node2D, data : AttackData):
	#TODO
	allHurtboxesOff()
	print("most én, p"+ str(player_id) + " megütöm " + body.name +"-t")
	var force = Vector2(data.force.x * (-1 if facingLeft else 1), data.force.y)
	# return AttackData.new(data.name, dmg, force, data.stunTime)
	body.hit(AttackData.new(data.name, data.dmg, force, data.stunTime + (0 if data.name in stunExceptionAttacks else plusStun)), strength, poison, stinger)



func update_state(direction: float) -> void:
	if currentState == PlayerState.Attack:
		attacking()
	elif currentState == PlayerState.Dash:
		dash_move()
	elif inputBuffers["p"+str(player_id)+"heavy"] > 0 and canAttack:
		inputBuffers["p"+str(player_id)+"heavy"] = 0
		attack(true)
	elif inputBuffers["p"+str(player_id)+"attack"] > 0 and canAttack:
		inputBuffers["p"+str(player_id)+"attack"] = 0
		attack(false)
	elif not is_on_floor():
		change_state(PlayerState.Jump, "jump")
	elif abs(direction) > contiDeadzone:
		change_state(PlayerState.Run, "run")
	else:
		change_state(PlayerState.Idle, "idle")
		

func change_state(new_state: PlayerState, anim_name: String):
	if currentState == new_state:
		return
	currentState = new_state
	anim_player.play(anim_name)



func trampoline(force : Vector2):
	velocity = force
	trampoline_force = force
	knock_back_timer = knock_back_time

func jump(force : Vector2) ->void:
	velocity = force

func smash():
	velocity = Vector2(250,500)

func side_teleport():
	position.x += -50 if facingLeft else 50

func back_teleport():
	position.x -= -50 if facingLeft else 50

var finisher = false
var next = false
func finishing():
	finisher = true
	var activeInput

	if usingController:
		activeInput = "left" if Input.get_joy_axis(controller_id, JOY_AXIS_LEFT_X) < 0 else "right"
	else:
		activeInput = "left" if Input.get_axis("p"+str(player_id)+"left", "p"+str(player_id)+"right") < 0 else "right"
	if (facingLeft and activeInput == "left") or (not facingLeft and activeInput == "right"):
		anim_player.play("sword_side_heavy_finish1")
	else:
		finisher = false
		next = true
		anim_player.play("sword_side_heavy_finish2")

var second = false
func down_heavy_2():
	second = true

func attack(heavy : bool) -> void:
	canAttack = false
	currentState = PlayerState.Attack
	#nagyon utalom ezt az egeszet
	#get attack type (neutral, side, down, air?)

	if is_on_floor():
		canMove = false
		if usingController:
			var y = Input.get_joy_axis(controller_id, JOY_AXIS_LEFT_Y)
			var x = abs(Input.get_joy_axis(controller_id, JOY_AXIS_LEFT_X))
			if y > contiDeadzone:
				attackType = "down"
			elif x > contiDeadzone:
				attackType = "side"
			else:
				attackType = "neutral"
		else:
			if Input.is_action_pressed("p"+str(player_id)+"down"):
				attackType = "down"
			elif Input.is_action_pressed("p"+str(player_id)+"side"):
				attackType = "side"
			else:
				attackType = "neutral"
	else: # in the air
		if usingController:
			var y = Input.get_joy_axis(controller_id, JOY_AXIS_LEFT_Y)
			var x = abs(Input.get_joy_axis(controller_id, JOY_AXIS_LEFT_X))
			if y < (-1*contiDeadzone):
				attackType = "nair"
			elif y > contiDeadzone:
				attackType = "dair"
			elif x > contiDeadzone:
				attackType = "nair"
			else:
				attackType = "nair"
		else: #keyboard
			if Input.is_action_pressed("p"+str(player_id)+"up"):
				attackType = "nair"
			elif Input.is_action_pressed("p"+str(player_id)+"down"):
				attackType = "dair"
			elif Input.is_action_pressed("p"+str(player_id)+"side"):
				attackType = "nair"
			else:
				attackType = "nair"
	if attackType == "nair":
		if nairCount >= 2:
			canMove = true
			canAttack = true
			change_state(PlayerState.Jump, "jump")
			return
		nairCount += 1
	var weight = "_heavy" if heavy else ""
	anim_player.play(weapon+"_"+attackType + weight)

func attacking()->void:
	var t = $AnimationPlayer.current_animation_position
	var attack = weapon+"_"+attackType
	match attack:
		"sword_side":
			if 0.2 < t and t < 0.3:
				velocity.x = (-1 if facingLeft else 1) * 400
		"sword_nair":
			if 0.15 < t and t < 0.25:
				velocity.y = -200
		"sword_nair_heavy":
			if 0.15 < t and t < 0.25:
				velocity.y = -200



func dash_move()->void:
	velocity.x = horizontal * horizontalDashForce
	velocity.y = vertical * verticalDashForce

func dash() -> void:
	canDash = false
	canMove = false
	hurtable = false
	change_state(PlayerState.Dash, "dash")
	
	if usingController:
		horizontal = (1 if Input.get_joy_axis(controller_id, JOY_AXIS_LEFT_X) > contiDeadzone else 0) + (-1 if Input.get_joy_axis(controller_id, JOY_AXIS_LEFT_X) < (-1*contiDeadzone) else 0)
		vertical = (1 if (Input.get_joy_axis(controller_id, JOY_AXIS_LEFT_Y) > contiDeadzone) else 0) + (-1 if (Input.get_joy_axis(controller_id, JOY_AXIS_LEFT_Y) < (-1 * contiDeadzone)) else 0) 
		
	else:
		var right = Input.is_action_pressed("p"+str(player_id)+"right")
		var up = Input.is_action_pressed("p"+str(player_id)+"up")
		var down = Input.is_action_pressed("p"+str(player_id)+"down")
		var left = Input.is_action_pressed("p"+str(player_id)+"left")
		horizontal = (1 if right else 0) + (-1 if left else 0)
		vertical = (-1 if up else 0) + (1 if down else 0)
	var supper = 0
	if horizontal == 0 and vertical == 0:
		supper = 0.1
	velocity.x = (horizontal * horizontalDashForce)
	velocity.y = (vertical * verticalDashForce)
	dashVertical = vertical
	dashHorizontal = horizontal
	
	await get_tree().create_timer(anim_player.get_animation("dash").length+supper).timeout
	canMove = true
	hurtable = true
	
	#afterwork
	if is_on_floor():
		change_state(PlayerState.Run, "run")
	else:
		change_state(PlayerState.Jump, "jump")
	await get_tree().create_timer(dashCooldown).timeout
	canDash = true

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	print("anim ended")
	if anim_name in noAttackAnims:
		return
	allHurtboxesOff()
	if hitSomething or attackType.contains("air"):
		canMove = true
		canAttack = true
	else:
		await get_tree().create_timer(missPunish).timeout
		canMove = true
		canAttack = true
	if (velocity.x != 0):
		change_state(PlayerState.Run, "run")
	else:
		change_state(PlayerState.Idle, "idle")
	hitSomething = false
	finisher = false
	next = false
	second = false
	hitCount = 0


func takeDamage():
	if not hurtable:
		return
	else:
		hp -=10

# AREA SIGNALS

func _on_hurt_body_entered(body: Node2D) -> void:
	takeDamage()


func _sword_neutral_hit(body: Node2D) -> void:
	if body.is_in_group("player"+str(player_id)):
		return
	hitSomething = true
	hit_opponent(body, attacks["sword_neutral"])


func _sword_side_hit(body: Node2D) -> void:
	if body.is_in_group("player"+str(player_id)):
		return
	hitSomething = true
	hit_opponent(body, attacks["sword_side"])


func sword_down_hit(body: Node2D) -> void:
	if body.is_in_group("player"+str(player_id)):
		return
	hitSomething = true
	# dmg and force
	hit_opponent(body, attacks["sword_down"])
	

func sword_nair_hit(body: Node2D) -> void:
	if body.is_in_group("player"+str(player_id)):
		return
	hitSomething = true
	# dmg and force
	hit_opponent(body, attacks["sword_nair"])




func dair_hit(body: Node2D) -> void:
	if body.is_in_group("player"+str(player_id)):
		return
	hitSomething = true
	velocity.y = -300
	# dmg and force
	hit_opponent(body, attacks["sword_dair"])

func clash():
	allHurtboxesOff()
	var clashForce = attacks["clash"].force
	print("clashing, state: "+ str(currentState))
	hit(AttackData.new("clash",0,Vector2(clashForce.x * (1 if facingLeft else -1), clashForce.y), 0.2), strength, 0, 0)
	


func _on_button_pressed() -> void:
	var random_key = Mutator_Library.all_mutators.keys().pick_random()
	Mutator_Library.all_mutators["Pushy"].on_apply.call(self)


var hitCount = 0

func sword_heavy_neutral_hit(body: Node2D) -> void:
	if body.is_in_group("player"+str(player_id)):
		return
	hitSomething = true
	hitCount +=1
	# dmg and force
	hit_opponent(body, attacks["sword_heavy_neutral"+str(hitCount)])
	if (hitCount == 1):
		anim_player.play("sword_neutral_heavy2")
		
	if hitCount >= 2:
		hitCount = 0


func _on_sword_heavy_side_body_entered(body: Node2D) -> void:
	
	if body.is_in_group("player"+str(player_id)):
		return
	print("te budos cigany")
	hitSomething = true
	hitCount +=1
	if finisher:
		hit_opponent(body, attacks["sword_heavy_side2"])
	else:
		hit_opponent(body, attacks["sword_heavy_side1"])
	if hitCount == 1:
		anim_player.play("sword_side_heavy2")
	if next:
		facingLeft = not facingLeft
		finisher = true
		next = false


func _on_dodge_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"+str(player_id)):
		return
	var dashIrany = Vector2(0,0)
	dashIrany = Vector2(dashHorizontal * pushDodge * 1.2, dashVertical* pushDodge)
	print("ez egy dodge-os utes + state: " + str(currentState))
	body.hit(AttackData.new("dodge", attackDodge, dashIrany, stunDodge), strength, poison, stinger)
		


func _on_sword_heavy_down_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"+str(player_id)):
		return
	hitSomething = true
	if second:
		hit_opponent(body, attacks["sword_heavy_down2"])
	else:
		hit_opponent(body, attacks["sword_heavy_down1"])
