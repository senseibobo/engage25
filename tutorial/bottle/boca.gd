class_name TutorialBottle
extends Node3D

signal destroyed_bottle

@export var particle_scene: PackedScene
@export var visible_notifier: VisibleOnScreenNotifier3D

func _on_hitbox_got_hit() -> void:
	var particle = particle_scene.instantiate()
	get_parent().add_child(particle)
	particle.global_position = global_position
	particle.emitting = true
	emit_signal(&"destroyed_bottle")
	queue_free()
	await get_tree().process_frame.connect(Enemy.check_enemies_shootable)


func is_shootable():
	return visible_notifier.is_on_screen()
