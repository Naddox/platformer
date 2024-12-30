extends CharacterBody2D

@export_category("Player")
@export_range(50, 200) var SPEED: float = 130.0
@export_range(-500, -100) var JUMP_VELOCITY: float = -300.0

@onready var jump = $jump
@onready var animated_sprite = $AnimatedSprite2D
@onready var land = $land

var was_falling = false
var can_jump = true

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		was_falling = true
	
	# Detect landing
	if was_falling and is_on_floor():
		was_falling = false
		land.play()

	# Get the input direction: -1, 0, 1
	var direction = Input.get_axis("move_left", "move_right")
	
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
	
	# Play animations
	# Flip the sprite
	if is_on_floor():
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		animated_sprite.play("jump")
	
	if Input.is_action_pressed("crouch"):
		animated_sprite.play("jump")
		if Input.is_action_just_pressed("jump") and is_on_floor():
			can_jump = false
			collision_mask &= ~(1 << 2)
			await get_tree().create_timer(0.1).timeout
			collision_mask |= 1 << 2
			can_jump = true
	
	# Handle jump.
	if can_jump and Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		jump.play()
	
	# Apply movement
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
