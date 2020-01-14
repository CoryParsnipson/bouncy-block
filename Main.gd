extends Node

export var score = 0
export var level = 0
export var to_next_level = 1
export var barrier_speed = 7
export var barrier_offset_min = 0
export var barrier_offset_max = 0
export var barrier_gap_radius = 120

export var barrier_speed_max = 13
export var barrier_wait_time_min = 1.5
export var barrier_gap_radius_min = 70

var bounds
var game_started = false
var previous_barrier_pos_x

var active_barriers = Array()

func _ready():
	bounds = get_viewport().get_visible_rect()
	
	barrier_offset_min = int(bounds.position.y) + barrier_gap_radius
	barrier_offset_max = int(bounds.end.y) - barrier_gap_radius
	
	# make the upper barrier sprite mirrored to align the face
	$BarrierUpper/AnimatedSprite.flip_h = true
	
	reset()

func _process(delta):
	if !game_started:
		if $Player.is_jump_pressed():
			start_game()
			
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
	
	$BarrierUpper.position.x = bounds.position.x - $BarrierUpper/CollisionShape2D.shape.extents.x - 10
	$BarrierLower.position.x = bounds.position.x - $BarrierLower/CollisionShape2D.shape.extents.x - 10
	
	set_score(0)
	level = 0
	
	game_started = false
	$Player.disable_physics = true
	
func start_game():
	reset()
	
	# TODO: add 3 second countdown here before starting
	
	game_started = true
	$Player.disable_physics = false
	$Player.disable_input = false
	$BarrierTimer.start()
	
func game_over():
	# TODO: add timer so that if user presses space immediately, it waits a minimum of the timer timeout  before
	# starting a new game
	game_started = false
	$Player.disable_physics = true
	$Player.disable_input = true
	$BarrierTimer.stop()
	
func set_score(new_score):
	score = new_score
	$ScoreCounter.text = str(score)
	
func send_barrier():
	$BarrierUpper.position.x = bounds.end.x + $BarrierUpper/CollisionShape2D.shape.extents.x - 10
	$BarrierLower.position.x = bounds.end.x + $BarrierLower/CollisionShape2D.shape.extents.x - 10
	
	var barrier_offset = randi() % (barrier_offset_max - barrier_offset_min) + barrier_offset_min
	
	$BarrierUpper.position.y = barrier_offset - barrier_gap_radius
	$BarrierLower.position.y = barrier_offset + barrier_gap_radius
	
	#active_barriers.push(barrier)

func _on_BarrierTimer_timeout():
	send_barrier()

	if score % to_next_level == 0:
		level += 1
		
		$BarrierTimer.wait_time = max($BarrierTimer.wait_time - 0.02, barrier_wait_time_min)
		barrier_speed = min(barrier_speed + 1, barrier_speed_max)
		barrier_gap_radius = max(barrier_gap_radius - 5, barrier_gap_radius_min)
		
		barrier_offset_min = int(bounds.position.y) + barrier_gap_radius
		barrier_offset_max = int(bounds.end.y) - barrier_gap_radius
	
	$BarrierTimer.start()


func _on_barrier_collision(body):
	game_over()
