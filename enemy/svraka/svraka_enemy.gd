class_name SvrakaEnemy
extends Node3D


signal took_off
signal shots_queued


const START_SHOT_COUNT: int = 3


enum State {
	PERCH,
	TAKEOFF,
	DODGE,
	ATTACK,
	QUEUE,
	SHOOT,
	DIE
}


@export var animation_player: AnimationPlayer
@export var revolver: SvrakaRevolver
@export var queue_line_renderer: LineRenderer

var state: State = State.PERCH
var takeoff_target_position: Vector3 
var shot_count: int = START_SHOT_COUNT
var queued_shots: int = 0
var queued_shot_instances: Array[QueuedShot]
var shot_queue_positions: Array[Vector3]
var distance_from_player: float = 15.0
var old_position: Vector3

@onready var start_position: Vector3 = global_position
@onready var start_dir: Vector3 = global_basis.z.normalized()


func _ready():
	TimeManager.rewind_finished.connect(_on_rewind_finished)
	TimeManager.svraka_shoot_state_started.connect(_on_svraka_shoot_state_started)
	TimeManager.queue_state_started.connect(_on_queue_state_started)
	TimeManager.player_revived.connect(_on_player_revived)
	
	takeoff_target_position = start_position + start_dir * 5.0 + Vector3.UP*5.0


func start_fight():
	await take_off()
	TimeManager.start_queue_state()


func show_message(message: String):
	SceneManager.instance.show_message(message)


func _process(delta: float) -> void:
	animation_player.speed_scale = 1.0/Engine.time_scale
	match state:
		State.QUEUE: _process_queue(delta)
		State.SHOOT: _process_shoot(delta)


func take_off():
	shot_count = START_SHOT_COUNT
	state = State.TAKEOFF
	animation_player.play(&"Idlefly")
	var tween = create_tween()
	tween.tween_method(_process_takeoff,0.0,1.0,2.0)
	tween.tween_callback(TimeManager.start_high_noon_state)
	tween.tween_callback(took_off.emit)
	await took_off


func _process_takeoff(t: float):
	global_position = bezier(start_position, start_position + Vector3.UP*5.0, takeoff_target_position, t)


func _process_shoot(delta: float):
	var dir_to_player: Vector3 = global_position.direction_to(Player.instance.global_position)
	dir_to_player.y = 0.0
	dir_to_player = dir_to_player.normalized()
	var target_position: Vector3 = Player.instance.global_position - dir_to_player * distance_from_player
	global_position = lerp(global_position, target_position, 3*delta)
	look_at(Player.instance.global_position)
	rotation *= Vector3(0,1,0)
	rotation.y += PI


func _process_queue(delta: float):
	rotation.y = \
		-Vector2(old_position.x, old_position.z).\
		angle_to_point(Vector2(global_position.x, global_position.z)) + PI/2.0
	old_position = global_position


func _process_queue_old(delta: float):
	var t: float = TimeManager.current_time/TimeManager.queueing_total_time
	var next_shoot_t: float = float(queued_shots)/float(shot_count)
	var center: Vector3 = Player.instance.global_position + Vector3.UP*1.5
	var target_position: Vector3 = center + (-start_dir).rotated(Vector3.UP,-t*TAU) * distance_from_player
	global_position = lerp(global_position, target_position, delta)
	look_at(target_position)
	rotation *= Vector3(0,1,0)
	rotation.y += PI
	if t > next_shoot_t:
		queued_shots += 1
		queue_shot()


func queue_shot():
	var instance: QueuedShot = revolver.queue_shot(Player.instance.global_position + Vector3.UP*1.6)
	queued_shot_instances.append(instance)


func bezier(p0: Vector3, p1: Vector3, p2: Vector3, t: float):
	var q0 = p0.lerp(p1, t)
	var q1 = p1.lerp(p2, t)
	return q0.lerp(q1,t)


func _on_svraka_shoot_state_started():
	state = State.SHOOT
	animation_player.play(&"Idlefly")


func _on_queue_state_started():
	queued_shot_instances.clear()
	queued_shots = 0
	state = State.QUEUE
	animation_player.play(&"Idlefly")
	queue_line_renderer.visible_percent = 0.0
	calculate_queue_positions()
	start_queue_animation()
	shot_count += 1


func calculate_queue_positions():
	shot_queue_positions.clear()
	for i in shot_count:
		var t: float = float(i)/float(shot_count)
		var angle: float = t * TAU
		var center: Vector3 = Player.instance.global_position + Vector3.UP*2.0
		var around: Vector3 = start_dir.rotated(Vector3.UP, angle)*distance_from_player
		var vertical: Vector3 = Vector3.UP*(randf()*2-0.5)*3.0
		var pos: Vector3 = center + around + vertical
		shot_queue_positions.append(pos)
	shot_queue_positions.shuffle()
	shot_queue_positions.append(shot_queue_positions[0])
	queued_shots = shot_count
	queue_line_renderer.points = shot_queue_positions.duplicate()
	shot_queue_positions.remove_at(0)


var queue_shot_tween: Tween


func start_queue_animation():
	queue_line_renderer.visible_percent = 0.0
	var queue_time: float = TimeManager.queueing_total_time-1.0
	queue_shot_tween = create_tween().set_ignore_time_scale()
	var dt: float = float(queue_time)/float(shot_queue_positions.size())
	for pos: Vector3 in shot_queue_positions:
		queue_shot_tween.tween_property(self, ^"global_position", pos, dt)
		queue_shot_tween.tween_callback(queue_shot)


func _on_rewind_finished():
	if state != State.PERCH:
		TimeManager.start_queue_state()


func _on_player_revived():
	shot_count = START_SHOT_COUNT
	queue_line_renderer.visible_percent = 0.0


func _on_crystals_all_crystals_destroyed() -> void:
	start_dying()


func start_dying():
	state = State.DIE
	if queue_shot_tween and queue_shot_tween.is_running(): queue_shot_tween.kill()
	for queued_shot_instance: QueuedShot in queued_shot_instances:
		if is_instance_valid(queued_shot_instance):
			queued_shot_instance.queue_free()
	var tween = create_tween().set_ignore_time_scale().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "global_position", global_position + Vector3.UP*100.0, 6.0)
	TimeManager.start_normal_state()
