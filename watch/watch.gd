class_name Watch
extends Node3D


@export var animation_player: AnimationPlayer
@export var short_hand: Sprite2D
@export var long_hand: Sprite2D

var used: bool = false


func _process(delta: float) -> void:
	animation_player.speed_scale = 1.0/Engine.time_scale
	long_hand.rotation = (TimeManager.time_passed/TimeManager.normal_total_time)*PI/3.0
	short_hand.rotation = (TimeManager.time_passed/TimeManager.high_noon_time)*TAU


func _unhandled_input(event: InputEvent) -> void:
	if not Player.instance.dead:
		if event.is_action_pressed("rewind"):
			_on_rewind_pressed()
		elif event.is_action_pressed("fast_forward"):
			_on_fast_forward_pressed()
	else:
		if event.is_action_pressed("rewind"):
			used = true
			TimeManager.revive_player()


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
