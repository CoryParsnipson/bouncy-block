extends Node

export var barrier_speed = 7

var bounds
var game_started = false
var gap_center_min
var gap_center_max

var active_barriers = Array()

func _ready():
	bounds = get_viewport().get_visible_rect()
	
	gap_center_min = int(bounds.position.y) + 100
	gap_center_max = int(bounds.end.y) - 100
	
	# TODO: move barriers beyond viewport edge
	reset()

func _process(delta):
	if !game_started:
		if $Player.is_jump_pressed():
			start_game()
			
func _physics_process(delta):
	if !game_started:
		return
	
	# TODO: how to programmtically calculate when this node falls off the screen?
	if $Barrier.position.x > bounds.position.x - 14:
		$Barrier.position.x -= barrier_speed

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
	
func send_barrier(barrier = $Barrier):
	barrier.position.y = randi() % (gap_center_max - gap_center_min) + gap_center_min
	barrier.position.x = bounds.end.x + 14
	
	#active_barriers.push(barrier)

func _on_BarrierTimer_timeout():
	send_barrier()
	
	$BarrierTimer.wait_time -= 0.02
	barrier_speed += 1.02
	
	$BarrierTimer.start()
