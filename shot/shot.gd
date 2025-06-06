class_name Shot
extends Node3D


@export var raycast: RayCast3D
@export var impact_scene: PackedScene


func setup(pos: Vector3, direction: Vector3):
	global_position = pos
	look_at(direction)
	trigger()


func trigger():
	raycast.force_raycast_update()
	if raycast.is_colliding():
		print("petar")
		var collider: Node = raycast.get_collider()
		var impact: Node3D = impact_scene.instantiate()
		get_tree().current_scene.add_child(impact)
		impact.global_position = raycast.get_collision_point()
	await get_tree().create_timer(0.4, false).timeout
	queue_free()
