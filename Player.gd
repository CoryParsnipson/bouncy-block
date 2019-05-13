extends KinematicBody2D

export var velocity = Vector2()
export var acceleration = Vector2()

export var jump_accel = 800
export var gravity = Vector2(0, 30)

export var disable_input = false

export var max_vel = 0.0
export var min_vel = 0.0

var bounds = Rect2()

func _ready():
	max_vel = -jump_accel * 10
	min_vel = jump_accel * 10
	
	bounds = get_viewport_rect()
	
	$AnimatedSprite.play()

func _process(delta):
	if !disable_input:
		if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_select"):
			velocity.y = 0
			acceleration.y -= jump_accel
			
			# cut off the current animation and restart flap animation
			$AnimatedSprite.stop()
			$AnimatedSprite.animation = "flap"
			$AnimatedSprite.frame = 0
			
			$AnimatedSprite.play()
	
func _physics_process(delta):
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
