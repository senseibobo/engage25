extends Node


signal normal_state_started
signal slowed_state_started
signal rewind_state_started


enum State {
	NORMAL,
	REWINDING,
	SLOWED
}



var state: State = State.NORMAL
var current_time: float 
var normal_total_time: float = 3.0
var slowed_total_time: float = 2.0


func _ready():
	await get_tree().process_frame
	await get_tree().process_frame
	normal_state_started.emit()


func _process(delta: float) -> void:
	match state:
		State.NORMAL:
			current_time += delta/Engine.time_scale
			if current_time >= normal_total_time: start_slowed_state()
		State.SLOWED:
			current_time += delta/Engine.time_scale
			if current_time >= slowed_total_time: start_normal_state()
		State.REWINDING: pass
			#if current_time <= 0: start_normal_state()


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


func start_rewind_state():
	Engine.time_scale = 0.1
	state = State.REWINDING
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, ^"current_time", 0.0, 1.5*Engine.time_scale)
	tween.tween_callback(start_normal_state)
	rewind_state_started.emit()
