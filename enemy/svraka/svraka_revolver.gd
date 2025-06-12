class_name SvrakaRevolver
extends Node3D


@export var queued_shot_scene: PackedScene


var aiming_at_player: bool = false


@onready var start_rotation: Vector3 = rotation


func _process(delta):
	if aiming_at_player:
		look_at(Player.instance.global_position)


func queue_shot(to: Vector3):
	var queued_shot: QueuedShot = queued_shot_scene.instantiate()
	get_tree().current_scene.add_child(queued_shot)
	queued_shot.global_position = global_position
	queued_shot.look_at(to)
	return queued_shot


func aim_at_player():
	aiming_at_player = true


func stop_aiming():
	aiming_at_player = false
