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
	var shootable = not broken and visible_notifier.is_on_screen() and is_shootable_raycast()
	print(shootable, " A A A  ", not broken, " A A A ", visible_notifier.is_on_screen()," ", name)
	return shootable


func is_shootable_raycast():
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var params := PhysicsRayQueryParameters3D.new()
	params.collide_with_bodies = true
	params.collide_with_areas = false
	params.collision_mask = 9
	params.hit_back_faces = true
	params.hit_from_inside = true
	params.from = global_position + Vector3.UP*0.1
	params.to = Player.instance.global_position + Vector3.UP*0.9
	var result = space_state.intersect_ray(params)
	if result.size() == 0:
		return false
	if not result["collider"] is Player:
		return false
	return true
