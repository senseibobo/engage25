class_name QueuedShot
extends Node3D


@export var shot_scene: PackedScene
@export var shot_player: AudioStreamPlayer3D
@export var queue_player: AudioStreamPlayer3D


func _ready() -> void:
	TimeManager.svraka_shoot_state_started.connect(trigger_shot)
	scale.z = 1
	queue_player.play()


func trigger_shot():
	await get_tree().create_timer(randf()*0.3, false, false, true).timeout
	shot_player.reparent(get_parent(), true)
	shot_player.play()
	var shot: Shot = shot_scene.instantiate()
	shot.hit_player = true
	get_tree().current_scene.add_child(shot)
	shot.setup(global_position, -global_basis.z.normalized())
	shot.trigger()
	queue_free()
