extends Node


signal bell_rung
signal normal_state_started
signal slowed_state_started
signal rewind_state_started
signal fast_forward_state_started
signal enemy_shoot_state_started
signal player_revived
signal tick
signal tick_forward
signal tick_backward


enum State {
	NORMAL,
	ENEMY_SHOOT,
	REWIND,
	FAST_FORWARD,
	SLOWED
}


var state: State = State.NORMAL
var current_time: float 
var time_passed: float
var normal_total_time: float = 5.0
var slowed_total_time: float = 3.0
var enemy_shoot_total_time: float = 2.0
var high_noon_time: float = normal_total_time * 6 * 3
var old_time_passed: float


func _ready():
	get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN
	bell_rung.connect(_on_bell_rung)
	await get_tree().create_timer(0.2).timeout
	normal_state_started.emit.call_deferred()


func _process(delta: float) -> void:
	if Player.instance.dead: return
	match state:
		State.NORMAL:
			time_passed += delta/Engine.time_scale
			var old_current_time = current_time
			current_time = fmod(time_passed, normal_total_time)
			if old_current_time > current_time: 
				bell_rung.emit()
				start_slowed_state()
		State.SLOWED:
			current_time += delta/Engine.time_scale
			if current_time >= slowed_total_time: start_enemy_shoot_state()
		State.ENEMY_SHOOT:
			current_time += delta/Engine.time_scale
			if current_time >= enemy_shoot_total_time: start_normal_state()
		State.REWIND: pass
			#if current_time <= 0: start_normal_state()
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
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	Enemy.check_enemies_shootable()


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
	print("REWINDING")
	Engine.time_scale = 0.1
	state = State.REWIND
	var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, ^"current_time", 0.0, 4.5*Engine.time_scale)
	tween.parallel().tween_property(self,^"time_passed",time_passed-current_time, 1.5*Engine.time_scale )
	tween.tween_callback(start_normal_state)
	rewind_state_started.emit()


func start_fast_forward_state():
	Engine.time_scale = 0.1
	state = State.FAST_FORWARD
	fast_forward_state_started.emit()
	var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, ^"current_time", normal_total_time, 0.9*Engine.time_scale)
	tween.parallel().tween_property(self,^"time_passed",time_passed + (normal_total_time-current_time), 0.9*Engine.time_scale)
	tween.tween_callback(start_slowed_state)


func _on_bell_rung():
	var player := AudioStreamPlayer.new()
	player.stream = preload("res://sounds/bell.mp3")
	player.volume_db = 8
	add_child(player)
	player.play()
	player.finished.connect(player.queue_free)


func revive_player():
	current_time = normal_total_time
	start_rewind_state()
	Player.instance.revive()
	player_revived.emit()
