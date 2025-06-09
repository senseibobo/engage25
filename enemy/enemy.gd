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
@export var enemy_path: EnemyPath
@export var gravity: float = 9.0
@export var shoot_player: AudioStreamPlayer
@export var death_player: AudioStreamPlayer
@export var enemy_shot_scene: PackedScene
@export var active: bool = false
@export var visible_notifier: VisibleOnScreenNotifier3D
@export var mesh: MeshInstance3D

var state: State = State.NONE
var path: PackedVector3Array
var old_path: PackedVector3Array
var current_path_percentage: float = 0.0
var current_path_index: int = 0
var full_path_distance: float


func _ready():
	mesh.layers = 1
	randomize()
	TimeManager.normal_state_started.connect(_on_normal_state_started)
	TimeManager.slowed_state_started.connect(_on_slowed_state_started)
	TimeManager.fast_forward_state_started.connect(_on_fast_forward_state_started)
	TimeManager.enemy_shoot_state_started.connect(_on_enemy_shoot_state_started)
	TimeManager.player_revived.connect(_on_player_revived)
	TimeManager.slowed_state_ended.connect(_on_slowed_state_ended)
	TimeManager.next_time_started.connect(_on_next_time_started)
	TimeManager.start_paths.connect(start_path)
	TimeManager.rewind_finished.connect(_on_rewind_finished)


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
	#ghost_anim_player.seek(animation_position)
	var diff = _update_position()
	enemy_path.update_line_renderer_points(nav_agent)
	#if diff.length() > 0.01:
		#look_at(global_position + diff*Vector3(1,0,1))


func _process_aim(delta):
	if not active: return
	rotate_to_player()


func hit():
	mesh.layers = 1
	enemy_path.queue_free()
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
	var destination: Vector3 = \
		NavigationServer3D.map_get_closest_point(nav_agent.get_navigation_map(), attempt_pos)
	nav_agent.target_position = destination
	nav_agent.get_next_path_position()
	var new_path: PackedVector3Array = nav_agent.get_current_navigation_path()
	if new_path.size() == 0:
		new_path = PackedVector3Array([global_position, destination])
	set_path(new_path)
	#path_follow.progress = 0.0


func get_attempt_pos(): 
	#return Player.instance.global_position + Vector3.FORWARD.rotated(Vector3.UP, randf()*TAU)*10.0
	var dir = -Player.instance.global_basis.z.normalized()
	var angled_dir = dir.rotated(Vector3.UP,  randf_range(-PI/1.8, PI/1.8))
	var distance = randf_range(5.0,10.0)
	return Player.instance.global_position + angled_dir * distance


func set_path(new_path: PackedVector3Array):
	if not active: return
	if state == State.DEAD: return
	if path.size() > 2 and new_path.size() > 2:
		print("SETTING PATH FROM ", path[-1], " TO ", new_path[-1])
	old_path = path.duplicate()
	path = new_path.duplicate()
	enemy_path.set_path(path)
	print("setting path to a path with ", path.size(), " points")
	if state == State.WALK:
		enemy_path.setup_ghost()


		


func _update_position():
	if not active: return
	if state == State.DEAD: return
	var step_time: float = 0.4166666/TimeManager.normal_total_time
	var t: float = TimeManager.current_time/TimeManager.normal_total_time
	var S: float = t - fmod(t, step_time)
	var D: float = fmod(t, step_time)
	t = S + lerp(D,step_time,D/step_time)
	t = clamp(t,0,1)
	var old_position: Vector3 = global_position
	var new_position: Vector3 = enemy_path.get_position_from_progress(t)
	global_position = new_position
	var diff: Vector3 = new_position - old_position
	move_and_collide(Vector3.DOWN*0.5)
	return diff


func _process_movement(delta):
	if not active: return
	velocity.y -= gravity*delta
	move_and_slide()
	

func _on_normal_state_started():
	if not active: return
	if state in [State.NONE, State.AIM, State.WALK]:
		enemy_path.activate()
		state = State.WALK
		animation_player.play(&"Walk")
		animation_player.speed_scale = 0.0
	elif state == State.DEAD:
		animation_player.speed_scale = randf_range(0.8,1.3)


func _on_slowed_state_started():
	if not active: return
	if state == State.DEAD: return
	mesh.layers = 1 if not is_visible_raycast() else 5
	enemy_path.deactivate()
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
		
		animation_player.stop()
		animation_player.play(&"Shoot")
		animation_player.speed_scale = 0.0
		state = State.AIM
		#start_path(

func _on_fast_forward_state_started():
	if not active: return
	#await TimeManager.bell_rung
	#start_path()


func _on_hitbox_got_hit() -> void:
	if not active: return
	hit()


func _on_enemy_shoot_state_started():
	if state == State.DEAD or not active: return
	shoot()
	enemy_path.deactivate()


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
	#start_path()
	var enemy_shot: EnemyShot = enemy_shot_scene.instantiate()
	get_tree().current_scene.add_child(enemy_shot)
	enemy_shot.global_position = params.from
	enemy_shot.look_at(params.to)
	enemy_shot.scale.x = params.from.distance_to(target_pos)


func _on_player_revived():
	if not active: return
	if state == State.DEAD: return
	print("SAD")
	animation_player.play(&"Walk")
	animation_player.speed_scale = 0.0
	state = State.WALK
	#print("setting to old path")
	set_path(path)


func is_shootable():
	#print("OVDE VVVVV")
	#print(active)
	#print(is_visible_raycast())
	#print(visible_notifier.is_on_screen())
	#print(not state == State.DEAD)
	#print("OVDE ^^^^")
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
	#start_path()


func activate():
	await TimeManager.next_time_started
	mesh.layers = 5
	active = true
	state = State.WALK
	enemy_path.activate()
	_on_normal_state_started()
	start_path()
	animation_player.play(&"Walk")
	animation_player.speed_scale = 0.0


func _on_rewind_finished():
	if state == State.DEAD or not active: return
	nav_agent.target_position = Vector3()
	nav_agent.get_next_path_position()
	nav_agent.target_position = path[-1]
	nav_agent.get_next_path_position()


func _on_slowed_state_ended():
	pass
	#if not state == State.DEAD and active:
		#start_path()
