extends CharacterBody2D

#state things
enum PlayerState {Idle, Run, Attack, Jump, Dash}
var currentState: PlayerState;

func _ready() -> void:
	change_state(PlayerState.Idle, "idle")
	add_to_group("player"+str(player_id))
	inputBuffers = {
	("p"+str(player_id)+"attack") : 0.0,
	("p"+str(player_id)+"dash") : 0.0,
	("p"+str(player_id)+"jump") : 0.0
	}
	sprite.self_modulate = color
	#controllers
	var controllers = Input.get_connected_joypads()
	print(controllers)
	if controllers.size() >= player_id:
		controller_id = controllers[player_id-1] 
		print("lett connectelve")

@export var color = Color.WHITE
@export var coins = 0
@export var player_id = 1
var controller_id = -1
@onready var anim_player = $AnimationPlayer
@onready var sprite = $Sprite2D

var speed = 400
const JUMP_VELOCITY = -300.0
var canMove = true

var hp = 100
var jumpCount = 0
var maxJumps = 2
var facingLeft
var hurtable = true
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

var inputBuffers = {}
func _input(event):
	if controller_id != -1:
		print("contit vizsgalunk")
		if Input.is_joy_button_pressed(controller_id, JOY_BUTTON_X):
			inputBuffers["p"+str(player_id)+"attack"] = input_buffer_time
		if Input.is_joy_button_pressed(controller_id, JOY_BUTTON_A):
			inputBuffers["p"+str(player_id)+"jump"] = input_buffer_time
		if Input.is_joy_button_pressed(controller_id, JOY_BUTTON_B):
			inputBuffers["p"+str(player_id)+"dash"] = input_buffer_time
	else:
		for i in inputBuffers.keys():
			if event.is_action_pressed(i):
				inputBuffers[i] = input_buffer_time

func _physics_process(delta: float) -> void:
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
	

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = 0
	if controller_id != -1:
		direction = Input.get_joy_axis(controller_id, JOY_AXIS_LEFT_X)
	else:
		direction = Input.get_axis("p"+str(player_id)+"left", "p"+str(player_id)+"right")
	if canDash and inputBuffers["p"+str(player_id)+"dash"] > 0 and currentState != PlayerState.Dash and currentState != PlayerState.Attack:
		inputBuffers["p"+str(player_id)+"dash"] = 0
		dash(direction)
		return
	
	if direction and canMove:
		sprite.scale.x = -1 if direction < 0 else 1
		facingLeft = direction < 0
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
	
	
	
	#State Update
	update_state(direction)
	move_and_slide()

	
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
	elif abs(direction) > 0:
		change_state(PlayerState.Run, "run")
	else:
		change_state(PlayerState.Idle, "idle")
		

func change_state(new_state: PlayerState, anim_name: String):
	if currentState == new_state:
		return
	currentState = new_state
	anim_player.play(anim_name)

func attack() -> void:
	canAttack = false
	currentState = PlayerState.Attack
	#nagyon utalom ezt az egeszet
	#get attack type (neutral, side, down, air?)
	if is_on_floor():
		canMove = false
		if Input.is_action_pressed("p"+str(player_id)+"down"):
			attackType = "down"
		elif Input.is_action_pressed("p"+str(player_id)+"side"):
			attackType = "side"
		else:
			attackType = "neutral"
	else:
		if Input.is_action_pressed("p"+str(player_id)+"up"):
			attackType = "nair"
		elif Input.is_action_pressed("p"+str(player_id)+"down"):
			attackType = "down"
		elif Input.is_action_pressed("p"+str(player_id)+"side"):
			attackType = "side"
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
	if hitSomething or attackType == "nair":
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
	var force = Vector2(450* (-1 if facingLeft else 1),-50)
	body.hit(30, force)


func _sword_side_hit(body: Node2D) -> void:
	if body.is_in_group("player"+str(player_id)):
		return
	hitSomething = true
	var force = Vector2(600* (-1 if facingLeft else 1),0)
	body.hit(30, force)


func sword_down_hit(body: Node2D) -> void:
	if body.is_in_group("player"+str(player_id)):
		return
	hitSomething = true
	# dmg and force
	var force = Vector2(30* (-1 if facingLeft else 1),-200)
	body.hit(30, force)


func takeDamage():
	if not hurtable:
		return
	else:
		hp -=10
		print("p"+str(player_id)+" hp: "+ str(hp))

func hit(dmg: int, force: Vector2)->void:
	if not hurtable:
		return
	else:
		velocity = force
		hp-= dmg
		print("p"+str(player_id)+" hp: "+ str(hp))
		return

func _on_hurt_body_entered(body: Node2D) -> void:
	takeDamage()





func sword_nair_hit(body: Node2D) -> void:
	if body.is_in_group("player"+str(player_id)):
		return
	hitSomething = true
	# dmg and force
	var force = Vector2(30* (-1 if facingLeft else 1),-200)
	body.hit(30, force)
