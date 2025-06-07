class_name TutorialBottle
extends Node3D

signal destroyed_bottle

@export var particle_scene: PackedScene
@export var visible_notifier: VisibleOnScreenNotifier3D


var broken: bool = false

func _on_hitbox_got_hit() -> void:
	var particle = particle_scene.instantiate()
	get_parent().add_child(particle)
	particle.global_position = global_position
	particle.emitting = true
	emit_signal(&"destroyed_bottle")
	broken = true
	await get_tree().process_frame
	await get_tree().process_frame
	Enemy.check_enemies_shootable()
	queue_free()


func is_shootable():
	var shootable = not broken and visible_notifier.is_on_screen()
	print(shootable, " A A A  ", not broken, " A A A ", visible_notifier.is_on_screen())
	return shootable
