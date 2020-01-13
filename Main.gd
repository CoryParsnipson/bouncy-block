extends Node

export var score = 0
export var level = 0
export var to_next_level = 2
export var barrier_speed = 7
export var barrier_offset_min = 0
export var barrier_offset_max = 0
export var barrier_gap_radius = 120

export var barrier_speed_max = 25
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
	
	# TODO: move barriers beyond viewport edge
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
	if $BarrierUpper.position.x > bounds.position.x - 14:
		$BarrierUpper.position.x -= barrier_speed
	
	if $BarrierLower.position.x > bounds.position.x - 14:
		$BarrierLower.position.x -= barrier_speed
		
	if previous_barrier_pos_x >= $Player.position.x \
		and $BarrierUpper.position.x <= $Player.position.x:
		score += 1
		$LevelCounter.text = str(score)

func reset():
	randomize()
	
	$Player.position.x = 200
	$Player.position.y = bounds.size.y / 2.0
	
	game_started = false
	$Player.disable_physics = true
	
func start_game():
	game_started = true
	$Player.disable_physics = false
	$BarrierTimer.start()
	
func send_barrier():
	$BarrierUpper.position.x = bounds.end.x + 14
	$BarrierLower.position.x = bounds.end.x + 14
	
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
