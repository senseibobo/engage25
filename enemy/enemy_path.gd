class_name EnemyPath
extends Path3D

@export var path_follow: PathFollow3D
@export var line_renderer: LineRenderer
@export var ghost: Node3D
@export var ghost_mesh: MeshInstance3D
@export var ghost_anim_player: AnimationPlayer

var path: PackedVector3Array
var ghost_moving: bool = false

func _ready():
	deactivate()
	curve = curve.duplicate()


func _physics_process(delta: float) -> void:
	if visible:
		if not ghost_moving:
			ghost.look_at(Player.instance.global_position)
			ghost.rotation *= Vector3(0,1,0)


func activate():
	set_deferred(&"visible", true)
	ghost_moving = true
	line_renderer.visible_percent = 0.0
	var tween = create_tween().set_parallel().set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_CUBIC).set_ignore_time_scale()
	ghost_anim_player.play(&"Walk")
	ghost_anim_player.speed_scale = 0
	tween.tween_property(line_renderer, "visible_percent", 1.0, 1.0).from(0.0)
	tween.tween_method(set_ghost_t, 0.0, 1.0, 1.0)
	tween.chain()
	tween.tween_callback(stop_ghost)


func set_ghost_t(t: float):
	path_follow.progress_ratio = t
	ghost_mesh.set_instance_shader_parameter(&"body_alpha", ease(t,0.33)*0.15)
	ghost_mesh.set_instance_shader_parameter(&"head_alpha", ease(t,0.33)*0.15)
	ghost.global_position = path_follow.global_position
	align_ghost_to_floor()
	ghost_anim_player.seek(fmod(t*TimeManager.normal_total_time,0.833333))
	


func stop_ghost():
	ghost_anim_player.play(&"Shoot")
	ghost_moving = false


func deactivate():
	visible = false


func update_line_renderer_points(nav_agent: NavigationAgent3D):
	var new_path: Array = []
	new_path.append(get_parent().global_position)
	nav_agent.get_next_path_position()
	var start_index = nav_agent.get_current_navigation_path_index()
	var end_index = path.size()
	for i in range(start_index, end_index):
		new_path.append(path[i])
	#new_path.reverse()
	line_renderer.points = new_path


func set_path(path: PackedVector3Array):
	self.path = path
	curve.clear_points()
	if is_instance_valid(line_renderer):
		line_renderer.points = Array(path)
	for point: Vector3 in path:
		curve.add_point(point)
	curve.get_baked_length()


func setup_ghost():
	ghost.global_position = path[-1]
	#ghost.look_at(ghost.global_position + path[-2].direction_to(path[-1]))
	align_ghost_to_floor()


func align_ghost_to_floor():
	var result = raycast_down()
	if result.size() > 0:
		ghost.global_position = result["position"]


func raycast_down():
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var params := PhysicsRayQueryParameters3D.new()
	params.from = ghost.global_position
	params.to = ghost.global_position + Vector3.DOWN*2.0
	params.collision_mask = 1
	return space_state.intersect_ray(params)


func get_position_from_progress(t: float):
	path_follow.progress_ratio = t
	return path_follow.global_position
