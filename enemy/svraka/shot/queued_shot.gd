class_name QueuedShot
extends Node3D


@export var shot_scene: PackedScene


func _ready() -> void:
	TimeManager.svraka_shoot_state_started.connect(trigger_shot)
	scale.z = 20


func trigger_shot():
	var shot: Shot = shot_scene.instantiate()
	shot.hit_player = true
	get_tree().current_scene.add_child(shot)
	shot.setup(global_position, -global_basis.z.normalized())
	shot.trigger()
	queue_free()
