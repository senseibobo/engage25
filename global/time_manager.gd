extends Node


signal bell_rung
signal normal_state_started
signal slowed_state_started
signal slowed_state_ended
signal rewind_state_started
signal rewind_finished
signal fast_forward_state_started
signal fast_forward_state_ended
signal enemy_shoot_state_started
signal player_revived
signal tick
signal tick_forward
signal tick_backward
signal next_time_started
signal enemy_killed
signal player_hit
signal game_over
signal started_restarting
signal start_paths
signal svraka_shoot_state_started
signal svraka_shoot_state_ended
signal queue_state_started
signal queue_state_ended


enum State {
	NORMAL,
	ENEMY_SHOOT,
	REWIND,
	FAST_FORWARD,
	SLOWED,
	RESTARTING,
	QUEUE,
	SVRAKA_SHOOT,
	HIGH_NOON
}


var state: State = State.NORMAL
var current_time: float 
var time_passed: float
var normal_total_time: float = 5.0
var slowed_total_time: float = 3.0
var slowed_base_time: float = 3.0
var slowed_bonus_time: float = 2.0
var queueing_total_time: float = 3.0
var svraka_shoot_total_time: float = 2.5
var enemy_shoot_total_time: float = 2.0
var high_noon_time: float = normal_total_time * 6 * 3
var old_time_passed: float
var rewind_speed_multiplier: float = 1.0


func _ready():
	get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN
	bell_rung.connect(_on_bell_rung)
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame


func restart_time():
	Engine.time_scale = 1.0
	time_passed = 0.0
	current_time = 0.0
	state = State.NORMAL
	next_time_started.emit.call_deferred()
	normal_state_started.emit.call_deferred()


func _process(delta: float) -> void:
	if not is_instance_valid(Player.instance): return
	var scaled_delta: float = delta/Engine.time_scale
	if not Player.instance.dead:
		match state:
			State.NORMAL:
				time_passed += scaled_delta
				var old_current_time = current_time
				var ct = fmod(time_passed, normal_total_time)
				if old_current_time >= ct: 
					current_time = normal_total_time
					_on_normal_state_ended()
				else:
					current_time = ct
			State.SLOWED:
				current_time += scaled_delta
				if current_time >= slowed_total_time: 
					_on_slowed_state_ended()
			State.ENEMY_SHOOT:
				current_time += scaled_delta
				if current_time >= enemy_shoot_total_time: 
					next_time_started.emit()
					start_paths.emit()
					start_normal_state()
			State.REWIND:
				time_passed -= scaled_delta*rewind_speed_multiplier
				current_time -= scaled_delta*rewind_speed_multiplier
				rewind_speed_multiplier = move_toward(rewind_speed_multiplier, 1.0, scaled_delta*3)
				if current_time <= 0:
					time_passed = round(time_passed/normal_total_time)*normal_total_time
					current_time = 0.0
					start_normal_state()
					rewind_finished.emit()
			State.QUEUE:
				time_passed = high_noon_time
				current_time += scaled_delta
				if current_time >= queueing_total_time:
					current_time = queueing_total_time
					queue_state_ended.emit()
					start_svraka_shoot_state()
			State.SVRAKA_SHOOT:
				time_passed = high_noon_time
				current_time += scaled_delta
				if current_time >= svraka_shoot_total_time:
					current_time = svraka_shoot_total_time
					svraka_shoot_state_ended.emit()
					start_queue_state()
			State.HIGH_NOON:
				current_time += scaled_delta
				time_passed = high_noon_time
				current_time = fmod(current_time,1.0)
				
				#if current_time <= 0: start_normal_sAudioStreamPlayertate()
	if int(old_time_passed) < int(time_passed):
		tick.emit() 
		tick_forward.emit()
	elif int(time_passed) < int(old_time_passed):
		tick.emit()
		tick_backward.emit()
	old_time_passed = time_passed
	

func start_normal_state():
	normal_state_started.emit()
	state = State.NORMAL
	Engine.time_scale = 1.0
	current_time = 0.0


func start_slowed_state():
	slowed_state_started.emit()
	state = State.SLOWED
	Engine.time_scale = 0.01
	current_time = 0.0


func start_enemy_shoot_state():
	enemy_shoot_state_started.emit()
	state = State.ENEMY_SHOOT
	Engine.time_scale = 0.01
	current_time = 0.0
	await get_tree().process_frame
	await get_tree().process_frame
	check_all_enemies_dead()


func check_all_enemies_dead():
	for enemy in get_tree().get_nodes_in_group(&"enemy"):
		if enemy is Enemy:
			if not enemy.state == Enemy.State.DEAD: return
	start_normal_state()


func start_rewind_state():
	Engine.time_scale = 0.1
	state = State.REWIND
	rewind_state_started.emit()
	rewind_speed_multiplier = 2.0


func start_fast_forward_state():
	Engine.time_scale = 0.1
	state = State.FAST_FORWARD
	fast_forward_state_started.emit()
	var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT).set_ignore_time_scale()
	tween.tween_property(self, ^"current_time", normal_total_time, 0.9)
	tween.parallel().tween_property(self,^"time_passed",time_passed + (normal_total_time-current_time), 0.9)
	slowed_total_time = slowed_base_time + slowed_bonus_time * (1.0-current_time/normal_total_time)
	tween.tween_property(Engine, "time_scale", 1.0, 0.0)
	#tween.tween_callback(start_paths.emit)
	tween.tween_callback(_on_normal_state_ended)
	tween.tween_callback(fast_forward_state_ended.emit)


func _on_normal_state_ended():
	if Enemy.any_enemies_shootable():
		start_slowed_state()
		bell_rung.emit()
	elif Enemy.any_enemies_can_shoot():
		start_enemy_shoot_state()
		bell_rung.emit()
	else:
		if state != State.NORMAL:
			state = State.NORMAL
		start_paths.emit()
		current_time = 0.0
		next_time_started.emit()


func _on_bell_rung():
	var player := AudioStreamPlayer.new()
	player.stream = preload("res://sounds/bell.mp3")
	player.volume_db = 8
	add_child(player)
	player.play()
	player.finished.connect(player.queue_free)


func _on_slowed_state_ended():
	slowed_state_ended.emit()
	if Enemy.any_enemies_can_shoot():
		start_enemy_shoot_state()
	else:
		start_paths.emit()
		start_normal_state()


func revive_player():
	current_time = normal_total_time
	start_rewind_state()
	Player.instance.revive()
	player_revived.emit()


func end_game():
	game_over.emit()


func start_queue_state():
	state = State.QUEUE
	current_time = 0.0
	queue_state_started.emit()


func start_svraka_shoot_state():
	state = State.SVRAKA_SHOOT
	current_time = 0.0
	svraka_shoot_state_started.emit()


func start_high_noon_state():
	state = State.HIGH_NOON


func restart_game():
	state = State.RESTARTING
	started_restarting.emit()
	var tween = create_tween().set_ignore_time_scale()
	tween.tween_property(self, ^"time_passed", 0.0, 5.0)
	tween.tween_callback(func():
		restart_time()
		state = State.NORMAL
		Transition.transition_to(preload("res://global/scene_manager/scene_manager.tscn")))
