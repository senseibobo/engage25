extends Node


signal normal_state_started
signal slowed_state_started


enum State {
	NORMAL,
	SLOWED
}



var state: State = State.NORMAL
var current_time: float 
var normal_total_time: float = 10.0
var slowed_total_time: float = 2.0


func _ready():
	await get_tree().process_frame
	await get_tree().process_frame
	normal_state_started.emit()


func _process(delta: float) -> void:
	match state:
		State.NORMAL:
			current_time += delta/Engine.time_scale
			if current_time >= normal_total_time:
				slowed_state_started.emit()
				state = State.SLOWED
				Engine.time_scale = 0.01
				current_time = 0.0
		State.SLOWED:
			current_time += delta/Engine.time_scale
			if current_time >= slowed_total_time:
				normal_state_started.emit()
				state = State.NORMAL
				Engine.time_scale = 1.0
				current_time = 0.0
