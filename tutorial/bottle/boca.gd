extends Node3D

signal destroyed_bottle

@export var particle_scene: PackedScene

func _on_hitbox_got_hit() -> void:
	var particle = particle_scene.instantiate()
	get_parent().add_child(particle)
	particle.global_position = global_position
	particle.emitting = true
	emit_signal(&"destroyed_bottle")
	queue_free()
