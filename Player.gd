extends KinematicBody2D

export var velocity = Vector2()
export var acceleration = Vector2()

export var jump_accel = 150
export var gravity = Vector2(0, 45)

export var disable_physics = false
export var disable_input = false

var bounds = Rect2()

var max_vel = 0.0
var min_vel = 0.0

var is_jumping = false

func _ready():
	max_vel = -jump_accel * 10
	min_vel = jump_accel * 10
	
	bounds = get_viewport_rect()
	
	$AnimatedSprite.play()

func is_jump_just_pressed():
	return Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_select")
	
func is_jump_pressed():
	return Input.is_action_pressed("ui_accept") or Input.is_action_pressed("ui_select")

func _process(delta):
	if !disable_input:
		if is_jump_just_pressed():
			velocity.y = 0
			acceleration.y -= jump_accel
			
			# start flap timer (used for variable height jumps)
			is_jumping = true
			$FlapTimer.start()
			
			# play flap sound
			if randi() % 2:
				$FlapSound1.play(0)
			else:
				$FlapSound2.play(0)
			
			# cut off the current animation and restart flap animation
			$AnimatedSprite.stop()
			$AnimatedSprite.animation = "flap"
			$AnimatedSprite.frame = 0
			
			$AnimatedSprite.play()
	
func _physics_process(delta):
	if disable_physics:
		return
	
	if !is_jumping or !is_jump_pressed():
		acceleration /= 2
	
	velocity = velocity + acceleration + gravity
	position += velocity * delta
	
	position.x = clamp(position.x, bounds.position.x, bounds.end.x)
	position.y = clamp(position.y, bounds.position.y, bounds.end.y)
	
	# kill upward momentum if it hits the top
	if position.y == bounds.position.y:
		acceleration.y = 0
		velocity.y = 0

func _on_animation_finished():
	$AnimatedSprite.play("neutral")
	
func _on_reached_jump_apex():
	is_jumping = false
