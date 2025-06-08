class_name Enemy
extends CharacterBody3D


enum State {
	NONE,
	WALK,
	AIM,
	DEAD
}


@export var hitbox: Hitbox
@export var gun: Node3D
@export var animation_player: AnimationPlayer
@export var nav_agent: NavigationAgent3D
@export var path_3d: Path3D
@export var path_follow: PathFollow3D
@export var gravity: float = 9.0
@export var line_renderer: LineRenderer
@export var shoot_player: AudioStreamPlayer
@export var death_player: AudioStreamPlayer
@export var enemy_shot_scene: PackedScene
@export var active: bool = false
@export var visible_notifier: VisibleOnScreenNotifier3D
@export var ghost: Node3D
@export var ghost_anim_player: AnimationPlayer
@export var mesh: MeshInstance3D

var state: State = State.NONE
var path: PackedVector3Array
var old_path: PackedVector3Array
var current_path_percentage: float = 0.0
var current_path_index: int = 0
var full_path_distance: float


func _ready():
	mesh.layers = 1
	ghost.visible = false
	randomize()
	path_3d.curve = path_3d.curve.duplicate()
	TimeManager.normal_state_started.connect(_on_normal_state_started)
	TimeManager.slowed_state_started.connect(_on_slowed_state_started)
	TimeManager.fast_forward_state_started.connect(_on_fast_forward_state_started)
	TimeManager.enemy_shoot_state_started.connect(_on_enemy_shoot_state_started)
	TimeManager.player_revived.connect(_on_player_revived)
	TimeManager.next_time_started.connect(_on_next_time_started)


func _physics_process(delta):
	if not active: return
	match state:
		State.WALK: _process_walk(delta)
		State.AIM: _process_aim(delta)


func _process_walk(delta):
	if not active: return
	if state == State.DEAD: return
	rotate_to_player()
	var step_time: float = 0.4166666/TimeManager.normal_total_time
	var animation_position: float = fmod(TimeManager.current_time+step_time/2.0, animation_player.current_animation_length)
	animation_player.seek(animation_position)
	ghost.look_at(Player.instance.global_position)
	#ghost_anim_player.seek(animation_position)
	var diff = _update_position()
	var new_path: Array = []
	new_path.append(global_position + Vector3.UP*0.5)
	nav_agent.get_next_path_position()
	var start_index = nav_agent.get_current_navigation_path_index()
	var end_index = path.size()
	for i in range(start_index, end_index):
		new_path.append(path[i])
	new_path.reverse()
	line_renderer.points = new_path
	#if diff.length() > 0.01:
		#look_at(global_position + diff*Vector3(1,0,1))


func _process_aim(delta):
	if not active: return
	rotate_to_player()


func hit():
	mesh.layers = 1
	ghost.queue_free()
	line_renderer.queue_free()
	TimeManager.enemy_killed.emit()
	collision_layer = 0
	collision_mask = 0
	rotate_to_player()
	state = State.DEAD
	hitbox.queue_free()
	animation_player.speed_scale = 0.0
	animation_player.play(&"DIEE")
	death_player.play()
	await get_tree().process_frame
	await get_tree().process_frame
	check_enemies_shootable()


static func check_enemies_shootable():
	if not any_enemies_shootable():
		TimeManager._on_slowed_state_ended()
	elif TimeManager.state != TimeManager.State.SLOWED:
		TimeManager.start_slowed_state()
		TimeManager.bell_rung.emit()


static func any_enemies_shootable():
	for enemy in TimeManager.get_tree().get_nodes_in_group(&"enemy"):
		if enemy is Enemy or enemy is TutorialBottle:
			if enemy is Enemy: 
				if not enemy.active: 
					continue
			if enemy.is_shootable(): 
				print(enemy.name, " is still shootable")
				return true
	return false


static func any_enemies_can_shoot():
	for enemy in TimeManager.get_tree().get_nodes_in_group(&"enemy"):
		if enemy is Enemy:
			if enemy.can_shoot(): return true
	return false


func rotate_to_player():
	if not active: return
	look_at(Player.instance.global_position)
	rotation.x = 0
	rotation.z = 0


func start_path():
	if not active: return
	if state == State.DEAD: return
	var attempt_pos: Vector3 = get_attempt_pos()
	print(attempt_pos)
	var destination: Vector3 = \
		NavigationServer3D.map_get_closest_point(nav_agent.get_navigation_map(), attempt_pos)
	nav_agent.target_position = destination
	nav_agent.get_next_path_position()
	path = nav_agent.get_current_navigation_path()
	if path.size() == 0:
		path = PackedVector3Array([global_position, destination])
	set_path(path)
	path_follow.progress = 0.0


func get_attempt_pos(): 
	#return Player.instance.global_position + Vector3.FORWARD.rotated(Vector3.UP, randf()*TAU)*10.0
	var dir = -Player.instance.global_basis.z.normalized()
	var angled_dir = dir.rotated(Vector3.UP,  randf_range(-PI/1.8, PI/1.8))
	var distance = randf_range(5.0,10.0)
	return Player.instance.global_position + angled_dir * distance


func set_path(new_path: PackedVector3Array):
	if not active: return
	if state == State.DEAD: return
	print("SETTING PATH FROM ", path[path.size()-1], " TO ", new_path[path.size()-1])
	old_path = path
	path = new_path
	path_3d.curve.clear_points()
	if is_instance_valid(line_renderer):
		line_renderer.points = Array(new_path)
	for point: Vector3 in path:
		path_3d.curve.add_point(point)
	path_3d.curve.get_baked_length()
	if state == State.WALK:
		print("ghooost")
		setup_ghost()


func setup_ghost():
	ghost.visible = true
	ghost.global_position = path[-1]
	#ghost.look_at(ghost.global_position + path[-2].direction_to(path[-1]))
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var params := PhysicsRayQueryParameters3D.new()
	params.from = ghost.global_position
	params.to = ghost.global_position + Vector3.DOWN*2.0
	params.collision_mask = 1
	var result = space_state.intersect_ray(params)
	if result.size() > 0:
		ghost.global_position = result["position"]
		


func _update_position():
	if not active: return
	if state == State.DEAD: return
	var step_time: float = 0.4166666/TimeManager.normal_total_time
	var t: float = TimeManager.current_time/TimeManager.normal_total_time
	var S: float = t - fmod(t, step_time)
	var D: float = fmod(t, step_time)
	t = S + lerp(D,step_time,D/step_time)
	t = clamp(t,0,1)
	path_follow.progress_ratio = t
	var destination: Vector3 = path_follow.global_position
	var diff: Vector3 = destination - global_position
	#var collision = move_and_collide(diff)
	#global_position = lerp(global_position, destination, 10*get_physics_process_delta_time()/Engine.time_scale)
	global_position = destination
	move_and_collide(Vector3.DOWN*0.5)
	return diff


func _process_movement(delta):
	if not active: return
	velocity.y -= gravity*delta
	move_and_slide()
	

func _on_normal_state_started():
	if not active: return
	if state in [State.NONE, State.AIM]:
		line_renderer.visible = true
		state = State.WALK
		animation_player.play(&"Walk")
	elif state == State.DEAD:
		animation_player.speed_scale = randf_range(0.8,1.3)


func _on_slowed_state_started():
	if not active: return
	if state == State.DEAD: return
	ghost.visible = false
	if state == State.WALK:
		global_position = path[-1]
		
		var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
		var params := PhysicsRayQueryParameters3D.new()
		params.from = global_position
		params.to = global_position + Vector3.DOWN*2.0
		params.collision_mask = 1
		var result = space_state.intersect_ray(params)
		if result.size() > 0:
			global_position = result["position"]
		
		line_renderer.visible = false
		animation_player.stop()
		animation_player.play(&"Shoot")
		animation_player.speed_scale = 0.0
		state = State.AIM


func _on_fast_forward_state_started():
	if not active: return
	await TimeManager.bell_rung
	start_path()


func _on_hitbox_got_hit() -> void:
	if not active: return
	hit()


func _on_enemy_shoot_state_started():
	if not active: return
	if state != State.DEAD:
		shoot()


func shoot():
	if not active: return
	animation_player.speed_scale = 1.0/Engine.time_scale
	shoot_player.play()
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var params := PhysicsRayQueryParameters3D.new()
	params.from = gun.global_position
	params.to = Player.instance.global_position + Vector3.UP*1.5
	var result: Dictionary = space_state.intersect_ray(params)
	var target_pos: Vector3 = params.to
	if result.size() > 0:
		var collider: Node = result["collider"]
		target_pos = result["position"]
		if collider is Player:
			target_pos = Player.instance.camera.global_position + Vector3.ONE.rotated(Vector3.UP, randf()*TAU)*0.1
			collider.hit()
		elif collider is Enemy:
			collider.hit()
	var enemy_shot: EnemyShot = enemy_shot_scene.instantiate()
	get_tree().current_scene.add_child(enemy_shot)
	enemy_shot.global_position = params.from
	enemy_shot.look_at(params.to)
	enemy_shot.scale.x = params.from.distance_to(target_pos)


func _on_player_revived():
	if not active: return
	if state == State.DEAD: return
	animation_player.play(&"Walk")
	state = State.WALK
	print("setting to old path")
	set_path(old_path)


func is_shootable():
	print("OVDE VVVVV")
	print(active)
	print(is_visible_raycast())
	print(visible_notifier.is_on_screen())
	print(not state == State.DEAD)
	print("OVDE ^^^^")
	return \
		active and \
		is_visible_raycast() and \
		visible_notifier.is_on_screen() and \
		not state == State.DEAD


func is_visible_raycast():
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var params := PhysicsRayQueryParameters3D.new()
	params.collide_with_bodies = true
	params.collide_with_areas = false
	params.collision_mask = 9
	params.hit_back_faces = true
	params.hit_from_inside = true
	params.from = global_position + Vector3.UP*1.6
	params.to = Player.instance.global_position + Vector3.UP*1.6
	var result = space_state.intersect_ray(params)
	if result.size() == 0:
		return false
	if not result["collider"] is Player:
		return false
	return true
	


func can_shoot():
	return is_visible_raycast() and active and state in [State.WALK, State.AIM]


func _on_next_time_started():
	if not active: return
	start_path()


func activate():
	await TimeManager.next_time_started
	mesh.layers = 5
	active = true
	state = State.WALK
	_on_normal_state_started()
	start_path()
	animation_player.play(&"Walk")
