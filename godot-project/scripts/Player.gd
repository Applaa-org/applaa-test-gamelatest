extends CharacterBody2D

signal hit_obstacle

# Car physics properties
@export var acceleration: float = 500.0
@export var max_speed: float = 800.0
@export var friction: float = 600.0
@export var turn_speed: float = 3.5

var steer_direction: float = 0.0

func _physics_process(delta: float):
	# Get input
	var input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# Steering
	steer_direction = input_direction.x
	
	# Apply rotation
	if velocity.length() > 10: # Only allow turning when moving
		rotation += steer_direction * turn_speed * delta
	
	# Apply acceleration/braking
	if input_direction.y != 0:
		velocity += Vector2.UP.rotated(rotation) * acceleration * input_direction.y * delta
		velocity = velocity.limit_length(max_speed)
	else:
		# Apply friction when not accelerating
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

	# Move the car
	move_and_slide()

	# Check for collisions with static bodies (like walls)
	var collision = move_and_collide(velocity * delta)
	if collision:
		# Simple bounce effect
		velocity = velocity.bounce(collision.get_normal())

func die():
	hit_obstacle.emit()
	# Hide the player temporarily
	hide()
	# Stop further processing
	set_physics_process(false)