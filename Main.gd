extends Node

export var barrier_speed_min = 7
export var barrier_speed_max = 13
export var barrier_wait_time_min = 1.5
export var barrier_wait_time_max = 3
export var barrier_gap_radius_min = 80
export var barrier_gap_radius_max = 120
export var barrier_min_buffer = 50
export var barrier_max_buffer = 100
export var foreground_speed = 20

export var score = 0
export var level = 0
export var to_next_level = 10
export var barrier_speed = 0
export var barrier_offset_min = 0
export var barrier_offset_max = 0
export var barrier_gap_radius = 0

var bounds
var input_disabled = false
var game_started = false
var previous_barrier_pos_x

var active_barriers = Array()

func _ready():
	bounds = get_viewport().get_visible_rect()
	
	# make the upper barrier sprite mirrored to align the face
	$BarrierUpper/AnimatedSprite.flip_h = true
	
	reset()
	$NotificationLabel.text = "Press Space or\nClick to start"


func _process(delta):
	if !game_started and !input_disabled:
		if Input.is_action_pressed("ui_accept") or Input.is_action_pressed("ui_select"):
			start_game()
			
	if game_started:
		$Foreground/Foreground1.position.x -= foreground_speed
		$Foreground/Foreground2.position.x -= foreground_speed
		
		if $Foreground/Foreground1.position.x + $Foreground/Foreground1.texture.get_size().x <= 0:
			$Foreground/Foreground1.position.x += bounds.size.x + $Foreground/Foreground1.texture.get_size().x
			
		if $Foreground/Foreground2.position.x + $Foreground/Foreground2.texture.get_size().x <= 0:
			$Foreground/Foreground2.position.x += bounds.size.x + $Foreground/Foreground2.texture.get_size().x


func _physics_process(delta):
	if !game_started:
		return
		
	previous_barrier_pos_x = $BarrierUpper.position.x
	
	# TODO: how to programmtically calculate when this node falls off the screen?
	if $BarrierUpper.position.x >= bounds.position.x - $BarrierUpper/CollisionShape2D.shape.extents.x - 10:
		$BarrierUpper.position.x -= barrier_speed
	
	if $BarrierLower.position.x >= bounds.position.x - $BarrierLower/CollisionShape2D.shape.extents.x - 10:
		$BarrierLower.position.x -= barrier_speed
		
	if previous_barrier_pos_x >= $Player.position.x \
		and $BarrierUpper.position.x <= $Player.position.x:
		set_score(score + 1)


func reset():
	randomize()
	
	$Player.position.x = 200
	$Player.position.y = bounds.size.y / 2.0
	
	$Player.velocity = Vector2(0, 0)
	$Player.acceleration = Vector2(0, 0)
	
	$BarrierTimer.wait_time = barrier_wait_time_max
	barrier_speed = barrier_speed_min
	
	set_barrier_gap_radius(barrier_gap_radius_max)
	
	$BarrierUpper.position.x = bounds.position.x - $BarrierUpper/CollisionShape2D.shape.extents.x - 10
	$BarrierLower.position.x = bounds.position.x - $BarrierLower/CollisionShape2D.shape.extents.x - 10
	
	set_score(0)
	level = 0
	
	$NotificationLabel.text = ""
	
	game_started = false
	$Player.disable_physics = true
	$Player.disable_input = true


func start_game():
	reset()
	
	game_started = true
	$Player.disable_physics = false
	$Player.disable_input = false
	$Player.visible = true
	
	$Foreground/Foreground1.texture = load("res://sprite/foreground.png")
	$Foreground/Foreground2.texture = load("res://sprite/foreground.png")
	
	$BarrierTimer.start()


func game_over():
	input_disabled = true
	game_started = false
	$Player.disable_physics = true
	$Player.disable_input = true
	$Player.visible = false
	$BarrierTimer.stop()
	
	$DeathStartTimer.start();
	$GameOverTimer.start();


func die():
	$DeathSound.play(0)
	
	$Foreground/Foreground1.texture = load("res://sprite/foreground2.png")
	$Foreground/Foreground2.texture = load("res://sprite/foreground2.png")
	
	# death animation
	$DeathPop.visible = true
	$DeathPop.position.x = $Player.position.x - 45
	$DeathPop.position.y = $Player.position.y - 45
	
	$DeathAnimationTimer.start()


func update_death_animation():
	move_death_pop($DeathPop/DeathPop1, deg2rad(0))
	move_death_pop($DeathPop/DeathPop2, deg2rad(45))
	move_death_pop($DeathPop/DeathPop3, deg2rad(90))
	move_death_pop($DeathPop/DeathPop4, deg2rad(135))
	move_death_pop($DeathPop/DeathPop5, deg2rad(180))
	move_death_pop($DeathPop/DeathPop6, deg2rad(225))
	move_death_pop($DeathPop/DeathPop7, deg2rad(270))
	move_death_pop($DeathPop/DeathPop8, deg2rad(315))


func move_death_pop(pop, angle):
	pop.position.x += cos(angle) * 50
	pop.position.y += sin(angle) * 50


func set_score(new_score):
	score = new_score
	$ScoreCounter.text = str(score)


func set_barrier_gap_radius(new_radius):
	barrier_gap_radius = max(new_radius, barrier_gap_radius_min)
	barrier_offset_min = int(bounds.position.y) + barrier_gap_radius + barrier_min_buffer
	barrier_offset_max = int(bounds.end.y) - barrier_gap_radius - barrier_max_buffer


func send_barrier():
	$BarrierUpper.position.x = bounds.end.x + $BarrierUpper/CollisionShape2D.shape.extents.x - 10
	$BarrierLower.position.x = bounds.end.x + $BarrierLower/CollisionShape2D.shape.extents.x - 10
	
	var barrier_offset = randi() % (barrier_offset_max - barrier_offset_min) + barrier_offset_min
	
	$BarrierUpper.position.y = barrier_offset - barrier_gap_radius
	$BarrierLower.position.y = barrier_offset + barrier_gap_radius


func _on_BarrierTimer_timeout():
	send_barrier()

	if score % to_next_level == 0:
		level += 1
		
		$BarrierTimer.wait_time = max($BarrierTimer.wait_time - 0.02, barrier_wait_time_min)
		barrier_speed = min(barrier_speed + 1, barrier_speed_max)
		set_barrier_gap_radius(barrier_gap_radius - 5)
	
	$BarrierTimer.start()


func _on_barrier_collision(body):
	game_over()


func _on_floor_collision(body):
	game_over()


func game_over_end():
	$DeathPop.visible = false
	$DeathPop/DeathPop1.position.x = $DeathPop.position.x
	$DeathPop/DeathPop1.position.y = $DeathPop.position.y
	$DeathPop/DeathPop2.position.x = $DeathPop.position.x
	$DeathPop/DeathPop2.position.y = $DeathPop.position.y
	$DeathPop/DeathPop3.position.x = $DeathPop.position.x
	$DeathPop/DeathPop3.position.y = $DeathPop.position.y
	$DeathPop/DeathPop4.position.x = $DeathPop.position.x
	$DeathPop/DeathPop4.position.y = $DeathPop.position.y
	$DeathPop/DeathPop5.position.x = $DeathPop.position.x
	$DeathPop/DeathPop5.position.y = $DeathPop.position.y
	$DeathPop/DeathPop6.position.x = $DeathPop.position.x
	$DeathPop/DeathPop6.position.y = $DeathPop.position.y
	$DeathPop/DeathPop7.position.x = $DeathPop.position.x
	$DeathPop/DeathPop7.position.y = $DeathPop.position.y
	$DeathPop/DeathPop8.position.x = $DeathPop.position.x
	$DeathPop/DeathPop8.position.y = $DeathPop.position.y
	
	$DeathAnimationTimer.stop()
	$NotificationLabel.text = "GAME OVER\n\nPress Space/Click to try again"
	input_disabled = false
