extends CharacterBody2D

#state things
enum PlayerState {Idle, Run, Attack, Jump, Dash}
var currentState: PlayerState;

func _ready() -> void:
	change_state(PlayerState.Idle, "idle")
	add_to_group("player2")


@onready var anim_player = $AnimationPlayer
@onready var sprite = $Sprite2D
@export var coins = 0
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
var horizontalDashForce = 400
var verticalDashForce = 200
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

func _physics_process(delta: float) -> void:
	$CanvasLayer/Label.text = "ALMA: " + str(coins)
	# Add the gravity.
	if not is_on_floor() and currentState != PlayerState.Dash:
		velocity += get_gravity() * delta
	
	if is_on_floor():
		jumpCount = 0
	# Handle jump.
	if Input.is_action_just_pressed("p2jump") and jumpCount < maxJumps and currentState != PlayerState.Attack:
		velocity.y = JUMP_VELOCITY
		jumpCount+=1
	

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("p2left", "p2right")
	if canDash and Input.is_action_just_pressed("p2dash") and currentState != PlayerState.Dash and currentState != PlayerState.Attack:
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
		return
	if currentState == PlayerState.Dash:
		dash_move()
		return
	if Input.is_action_just_pressed("p2attack") and canAttack:
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
	if Input.is_action_pressed("p2down"):
		attackType = "down"
		print("alma")
	elif Input.is_action_pressed("p2side"):
		attackType = "side"
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
				velocity.x = (-1 if facingLeft else 1) * 400
	move_and_slide()

func dash_move()->void:
	velocity.x = horizontal * horizontalDashForce
	velocity.y = vertical * verticalDashForce
	 
	move_and_slide()

func dash(direction) -> void:
	canDash = false
	canMove = false
	hurtable = false
	anim_player.play("dash")
	currentState = PlayerState.Dash
	
	var right = Input.is_action_pressed("p2right")
	var up = Input.is_action_pressed("p2up")
	var down = Input.is_action_pressed("p2down")
	var left = Input.is_action_pressed("p2left")
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
	if hitSomething:
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
	if body.is_in_group("player2"):
		return
	hitSomething = true
	var force = Vector2(450* (-1 if facingLeft else 1),-50)
	body.hit(30, force)


func _sword_side_hit(body: Node2D) -> void:
	if body.is_in_group("player2"):
		return
	hitSomething = true
	var force = Vector2(600* (-1 if facingLeft else 1),0)
	body.hit(30, force)


func sword_down_hit(body: Node2D) -> void:
	if body.is_in_group("player2"):
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
		print("p2 hp: "+ str(hp))
		
func hit(dmg: int, force: Vector2)->void:
	if not hurtable:
		return
	else:
		velocity = force
		hp-= dmg
		return

func _on_hurt_body_entered(body: Node2D) -> void:
	takeDamage()
