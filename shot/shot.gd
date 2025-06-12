class_name Shot
extends Node3D


@export var raycast: RayCast3D
@export var impact_scene: PackedScene
@export var anim_player: AnimationPlayer
@export var hit_player: bool = false


func setup(pos: Vector3, direction: Vector3, g: bool = true):
	global_position = pos
	look_at(int(g)*global_position + direction)
	trigger()
	anim_player.speed_scale = 1.0/Engine.time_scale


func trigger():
	if hit_player: raycast.collision_mask |= 8
	raycast.force_raycast_update()
	if raycast.is_colliding():
		var collider: Node = raycast.get_collider()
		if not hit_player and collider is Hitbox:
			collider.hit()
		elif hit_player and collider is Player:
			collider.hit()
		var impact: Node3D = impact_scene.instantiate()
		get_tree().current_scene.add_child(impact)
		impact.global_position = raycast.get_collision_point()
	await get_tree().create_timer(0.4, false, false, true).timeout
	queue_free()
