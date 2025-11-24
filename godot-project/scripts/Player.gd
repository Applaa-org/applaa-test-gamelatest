extends CharacterBody2D

signal hit_obstacle

# Car physics properties
@export var acceleration: float = 500.0
@export var max_speed: float = 800.0
@export var friction: float = 600.0
@export var turn_speed: float = 3.5

# Slide/Drift properties
@export var slide_turn_multiplier: float = 1.8
@export var slide_friction_reduction: float = 0.4

# Jump properties
var is_jumping: bool = false
var can_jump: bool = true

var steer_direction: float = 0.0

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D
@onready var jump_timer: Timer = $JumpTimer
@onready var jump_cooldown_timer: Timer = $JumpCooldownTimer

func _ready():
	jump_timer.timeout.connect(_on_jump_timer_timeout)
	jump_cooldown_timer.timeout.connect(_on_jump_cooldown_timer_timeout)

func _physics_process(delta: float):
	# Get input
	var input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var is_sliding = Input.is_action_pressed("slide") and velocity.length() > 100
	
	# Handle Jump Input
	if Input.is_action_just_pressed("jump") and can_jump and not is_jumping:
		_start_jump()

	# Determine current physics properties based on sliding state
	var current_turn_speed = turn_speed
	var current_friction = friction
	if is_sliding:
		current_turn_speed *= slide_turn_multiplier
		current_friction *= slide_friction_reduction

	# Steering
	steer_direction = input_direction.x
	
	# Apply rotation
	if velocity.length() > 10:
		rotation += steer_direction * current_turn_speed * delta
	
	# Apply acceleration/braking
	if input_direction.y != 0:
		velocity += Vector2.UP.rotated(rotation) * acceleration * input_direction.y * delta
		velocity = velocity.limit_length(max_speed)
	else:
		# Apply friction
		velocity = velocity.move_toward(Vector2.ZERO, current_friction * delta)

	# Move the car
	move_and_slide()

func _start_jump():
	is_jumping = true
	can_jump = false
	
	# Disable collision during jump
	collision_shape.set_deferred("disabled", true)
	
	jump_timer.start()
	jump_cooldown_timer.start()
	
	# Visual feedback for jump
	var tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(sprite, "scale", Vector2(0.15, 0.15), 0.25)
	tween.tween_property(sprite, "scale", Vector2(0.1, 0.1), 0.25)

func _on_jump_timer_timeout():
	is_jumping = false
	# Re-enable collision after jump
	collision_shape.set_deferred("disabled", false)

func _on_jump_cooldown_timer_timeout():
	can_jump = true

func die():
	hit_obstacle.emit()
	hide()
	set_physics_process(false)