extends CharacterBody2D

#state things


func _ready() -> void:
	change_state(PlayerState.Idle, "idle")
	add_to_group("player"+str(player_id))
	inputBuffers = {
	("p"+str(player_id)+"attack") : 0.0,
	("p"+str(player_id)+"dash") : 0.0,
	("p"+str(player_id)+"jump") : 0.0
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
	print(Szorp.p1color)
	print(Szorp.p2color)
	
	if player_id == 1:
		color = Szorp.p1color
	else:
		color = Szorp.p2color
	sprite.self_modulate = color
	attacks = {
		"sword_neutral" : AttackData.new(20, Vector2(400,-100)),
		"sword_side" : AttackData.new(20,Vector2(400,-100)),
		"sword_down" : AttackData.new(20,Vector2(400,-100)),
		"sword_nair" : AttackData.new(20,Vector2(400,-100)),
		"sword_dair" : AttackData.new(20,Vector2(400,-100)),
		"clash" : AttackData.new(0,Vector2(400,-200))
	}

class AttackData:
	var dmg: int
	var force: Vector2

	func _init(_damage, _force):
		dmg = _damage
		force = _force

enum PlayerState {Idle, Run, Attack, Jump, Dash, Hurt}
var currentState: PlayerState;

var color
@export var player_id = 1
@onready var label = $CanvasLayer/Label
@onready var anim_player = $AnimationPlayer
@onready var sprite = $Sprite2D
var attacks = []

var speed = 400
var canMove = true

var hp = 100
var facingLeft
var hurtable = true
#jumpi
const JUMP_VELOCITY = -300.0
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
var attackType = "neutral"
var canAttack = true;
var hitSomething = false
var attackCooldown = 0.2
var missPunish = 0.2
var attack_buffer = 0
var input_buffer_time = 0.2
var justJumped = false
var inputBuffers = {}

#
var stunned = false
var currentForce = Vector2(0,0)
var stunTimer = 0
var stunLength = 0.4

func _input(event):
	if usingController:
		var jump = Input.is_joy_button_pressed(controller_id, inputs["jump"])
		if Input.is_joy_button_pressed(controller_id, inputs["attack"]):
			inputBuffers["p"+str(player_id)+"attack"] = input_buffer_time
		if jump and not justJumped:
			inputBuffers["p"+str(player_id)+"jump"] = input_buffer_time
			print("jumping")
		if Input.is_joy_button_pressed(controller_id, inputs["dash"]):
			inputBuffers["p"+str(player_id)+"dash"] = input_buffer_time
		justJumped = jump
	else:
		for i in inputBuffers.keys():
			if event.is_action_pressed(i):
				inputBuffers[i] = input_buffer_time

func _physics_process(delta: float) -> void:
	if stunned:
		velocity.x = move_toward(velocity.x, 0, 1000 * delta)
		velocity += get_gravity() * delta
		stunTimer -= delta
		if stunTimer < 0:
			stunned = false
			if abs(velocity.x) > 0.3 and usingController:
				change_state(PlayerState.Run, "run")
			elif abs(velocity.x) > 0 and not usingController:
				change_state(PlayerState.Run, "run")
			else:
				change_state(PlayerState.Idle, "idle")
		

	else:
		for key in inputBuffers.keys():
			if inputBuffers[key] > 0:
				inputBuffers[key] -= delta
		
		# Add the gravity.
		if not is_on_floor() and currentState != PlayerState.Dash:
			velocity += get_gravity() * delta
	
		if is_on_floor():
			jumpCount = 0
		# Handle jump.
		if inputBuffers["p"+str(player_id)+"jump"] > 0 and jumpCount < maxJumps and currentState != PlayerState.Attack:
			inputBuffers["p"+str(player_id)+"jump"] = 0
			velocity.y = JUMP_VELOCITY
			jumpCount+=1
		var direction = 0
		if usingController:
			direction = Input.get_joy_axis(controller_id, JOY_AXIS_LEFT_X)
		else:
			direction = Input.get_axis("p"+str(player_id)+"left", "p"+str(player_id)+"right")
		if canDash and inputBuffers["p"+str(player_id)+"dash"] > 0 and currentState != PlayerState.Dash and currentState != PlayerState.Attack:
			inputBuffers["p"+str(player_id)+"dash"] = 0
			dash(direction)
			return
		
		if (direction > contiDeadzone or direction < (-1*contiDeadzone)) and canMove:
			sprite.scale.x = -1 if direction < 0 else 1
			facingLeft = direction < 0
			velocity.x = direction * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
		
		
		
		#State Update
		update_state(direction)
	move_and_slide()

func hit(data : AttackData)->void:
	if not hurtable:
		return
	else:
		#stun mechanic
		stunned = true
		stunTimer = stunLength
		sprite.scale.x = 1 if data.force.x > 0 else -1
		facingLeft = data.force.x < 0
		change_state(PlayerState.Hurt, "hurt")
		velocity = data.force
		hp-= data.dmg
		label.text = "PLAYER"+str(player_id)+" HP: "+str(hp)
		if hp <= 0:
			Szorp.i_lost(player_id)
			queue_free()
		return

	
func update_state(direction: float) -> void:
	if currentState == PlayerState.Attack:
		attacking()
	elif currentState == PlayerState.Dash:
		dash_move()
	elif inputBuffers["p"+str(player_id)+"attack"] > 0 and canAttack:
		inputBuffers["p"+str(player_id)+"attack"] = 0
		attack()
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
	print("state: "+ str(currentState))
	anim_player.play(anim_name)

func attack() -> void:
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
	anim_player.play(weapon+"_"+attackType)

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



func dash_move()->void:
	velocity.x = horizontal * horizontalDashForce
	velocity.y = vertical * verticalDashForce

func dash(direction) -> void:
	canDash = false
	canMove = false
	hurtable = false
	anim_player.play("dash")
	currentState = PlayerState.Dash
	
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
	
	velocity.x = (horizontal * horizontalDashForce)
	velocity.y = (vertical * verticalDashForce)
	
	await get_tree().create_timer(anim_player.get_animation("dash").length).timeout
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


func _sword_neutral_hit(body: Node2D) -> void:
	if body.is_in_group("player"+str(player_id)):
		return
	hitSomething = true
	body.hit(get_hit_data(attacks["sword_neutral"]))


func _sword_side_hit(body: Node2D) -> void:
	if body.is_in_group("player"+str(player_id)):
		return
	hitSomething = true
	body.hit(get_hit_data(attacks["sword_side"]))


func sword_down_hit(body: Node2D) -> void:
	if body.is_in_group("player"+str(player_id)):
		return
	hitSomething = true
	# dmg and force
	body.hit(get_hit_data(attacks["sword_down"]))


func takeDamage():
	if not hurtable:
		return
	else:
		hp -=10
		print("p"+str(player_id)+" hp: "+ str(hp))

func _on_hurt_body_entered(body: Node2D) -> void:
	takeDamage()

func sword_nair_hit(body: Node2D) -> void:
	if body.is_in_group("player"+str(player_id)):
		return
	hitSomething = true
	# dmg and force
	body.hit(get_hit_data(attacks["sword_nair"]))




func dair_hit(body: Node2D) -> void:
	if body.is_in_group("player"+str(player_id)):
		return
	hitSomething = true
	# dmg and force
	body.hit(get_hit_data(attacks["sword_dair"]))


func sword_neutral_clash(area: Area2D) -> void:
	print("Clash!")
	clash()
	
func clash():
	var clashForce = attacks["clash"].force
	hit(AttackData.new(0,Vector2(clashForce.x * (1 if facingLeft else -1), clashForce.y)))
	
func get_hit_data(data : AttackData)-> AttackData:
	var dmg = data.dmg
	var force = Vector2(data.force.x * (-1 if facingLeft else 1), data.force.y)
	return AttackData.new(dmg, force)
	
