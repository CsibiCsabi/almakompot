extends CharacterBody2D

#state things
enum PlayerState {Idle, Run, Attack, Jump, Dash}
var currentState: PlayerState = PlayerState.Run

func _ready() -> void:
	add_to_group("player")


@onready var anim_player = $AnimationPlayer
@onready var sprite = $Sprite2D
@export var coins = 0
var speed = 600
const JUMP_VELOCITY = -300.0
var canMove = true

var jumpCount = 0
var maxJumps = 2
#dash
var canDash = true
var dashLength = 400
var dashCooldown = 0.8

# weaponing
var weapon = "sword"
var attackType = "neutral"
var canAttack = true;
var attackCooldown = 0.2

func _physics_process(delta: float) -> void:
	$CanvasLayer/Label.text = "ALMA: " + str(coins)
	# Add the gravity.
	if not is_on_floor() and currentState != PlayerState.Dash:
		velocity += get_gravity() * delta
	
	if is_on_floor():
		jumpCount = 0
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and jumpCount < maxJumps and currentState != PlayerState.Attack:
		velocity.y = JUMP_VELOCITY
		jumpCount+=1
	

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	if canDash and Input.is_action_just_pressed("dash") and currentState != PlayerState.Dash and currentState != PlayerState.Attack:
		dash(direction)
		return
	
	if direction and canMove:
		$Sprite2D.flip_h = direction < 0
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
	
	
	
	#State Update
	update_state(direction)
	
	move_and_slide()

	
func update_state(direction: float) -> void:
	if currentState == PlayerState.Attack:
		attacking()
		return
	if currentState == PlayerState.Dash:
		dash_move()
		return
	if Input.is_action_just_pressed("attack") and canAttack:
		attack()
		return
	if not is_on_floor():
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
	canMove = false
	canAttack = false
	currentState = PlayerState.Attack
	#nagyon utalom ezt az egeszet
	#get attack type (neutral, side, down, air?)
	if Input.is_action_pressed("down"):
		attackType = "down"
		print("alma")
	elif Input.is_action_pressed("side"):
		attackType = "side"
		print("wth")
	else:
		attackType = "neutral"
	print(weapon+"_"+attackType)
	anim_player.play(weapon+"_"+attackType)

func attacking()->void:
	var t = $AnimationPlayer.current_animation_position
	var attack = weapon+"_"+attackType 
	match attack:
		"sword_side":
			if 0.2 < t and t < 0.3:
				velocity.x = (-1 if sprite.flip_h else 1) * 400
	move_and_slide()

func dash_move()->void:
	velocity.x = (-1 if sprite.flip_h else 1) * dashLength
	 
	move_and_slide()

func dash(direction) -> void:
	canDash = false
	canMove = false
	currentState = PlayerState.Dash
	if sprite.flip_h == true:
		direction = -1
	else:
		direction = 1
	$CollisionShape2D.disabled = true
	anim_player.play("dash")
	velocity.x = direction * dashLength
	velocity.y = 0
	await get_tree().create_timer(anim_player.get_animation("dash").length).timeout
	$CollisionShape2D.disabled = false
	canMove = true
	
	#afterwork
	if is_on_floor():
		change_state(PlayerState.Run, "run")
	else:
		change_state(PlayerState.Jump, "jump")
	await get_tree().create_timer(dashCooldown).timeout
	canDash = true

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	canMove = true
	if (velocity.x != 0):
		change_state(PlayerState.Run, "run")
	else:
		change_state(PlayerState.Idle, "idle")
	await get_tree().create_timer(attackCooldown).timeout
	canAttack = true
