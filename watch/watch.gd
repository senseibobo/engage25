class_name Watch
extends Node3D


@export var tick_player: AudioStreamPlayer
@export var animation_player: AnimationPlayer
@export var short_hand: Sprite2D
@export var long_hand: Sprite2D
@export var crystals: Array[Crystal]
@export var crystal_explode_particles: GPUParticles3D

var used: bool = false
var crystals_left: int = 3


func _ready():
	TimeManager.next_time_started.connect(_on_next_time_started)
	TimeManager.tick.connect(_on_tick)
	TimeManager.tick_backward.connect(_on_tick)
	TimeManager.player_hit.connect(_on_player_hit)


func _process(delta: float) -> void:
	animation_player.speed_scale = 1.0/Engine.time_scale
	var tp = TimeManager.time_passed
	var D = fmod(tp, 1.0)
	var S = tp - D
	tp = S + ease(D,0.03)
	long_hand.rotation = (tp/TimeManager.normal_total_time)*PI/3.0
	short_hand.rotation = (TimeManager.time_passed/TimeManager.high_noon_time)*TAU


func _unhandled_input(event: InputEvent) -> void:
	if not Player.instance.dead:
		if TimeManager.state == TimeManager.State.NORMAL:
			if event.is_action_pressed("rewind"):
				_on_rewind_pressed()
			elif event.is_action_pressed("fast_forward"):
				_on_fast_forward_pressed()
	else:
		if event.is_action_pressed("rewind") and Player.instance.fully_dead:
			if crystals_left > 0:
				destroy_crystal(3-crystals_left)
				used = true
				TimeManager.revive_player()
			else:
				TimeManager.restart_game()


func _on_rewind_pressed():
	if not used and TimeManager.state == TimeManager.State.NORMAL:
		animation_player.play(&"rewind")
		TimeManager.start_rewind_state()
		used = true
		await TimeManager.normal_state_started
		await TimeManager.normal_state_started
		used = false


func _on_fast_forward_pressed():
	if TimeManager.state == TimeManager.State.NORMAL:
		animation_player.play(&"fast_forward")
		TimeManager.start_fast_forward_state()


func _on_tick():
	tick_player.play()


func _on_player_hit():
	if crystals_left <= 0:
		TimeManager.end_game()
	

func destroy_crystal(index: int):
	crystals_left -= 1
	crystals[index].explode()


func _on_next_time_started():
	used = false
