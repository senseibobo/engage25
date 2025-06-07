class_name Enemy
extends CharacterBody3D


enum State {
	NONE,
	WALK,
	FASTFORWARD,
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
@export var shoot_player: AudioStreamPlayer3D


var state: State = State.NONE
var path: PackedVector3Array
var old_path: PackedVector3Array
var current_path_percentage: float = 0.0
var current_path_index: int = 0
var full_path_distance: float


func _ready():
	path_3d.curve = path_3d.curve.duplicate()
	TimeManager.normal_state_started.connect(_on_normal_state_started)
	TimeManager.slowed_state_started.connect(_on_slowed_state_started)
	TimeManager.fast_forward_state_started.connect(_on_fast_forward_state_started)
	TimeManager.enemy_shoot_state_started.connect(_on_enemy_shoot_state_started)
	TimeManager.player_revived.connect(_on_player_revived)


func _physics_process(delta):
	match state:
		State.WALK: _process_walk(delta)
		State.AIM: _process_aim(delta)


func _process_walk(delta):
	#rotate_to_player()
	var step_time: float = 0.4166666/TimeManager.normal_total_time
	animation_player.seek(
		fmod(TimeManager.current_time+step_time/2.0, animation_player.current_animation_length))
	var diff = _update_position()
	#if diff.length() > 0.01:
		#look_at(global_position + diff*Vector3(1,0,1))


func _process_aim(delta):
	rotate_to_player()


func hit():
	line_renderer.queue_free()
	collision_layer = 0
	collision_mask = 0
	rotate_to_player()
	state = State.DEAD
	hitbox.queue_free()
	animation_player.speed_scale = 0.0
	animation_player.play(&"DIEE")


func rotate_to_player():
	look_at(Player.instance.global_position)
	rotation.x = 0
	rotation.z = 0


func start_path():
	if state == State.DEAD: return
	var attempt_pos: Vector3 = global_position + Vector3.FORWARD.rotated(Vector3.UP, randf()*TAU)*10.0
	var destination: Vector3 = \
		NavigationServer3D.map_get_closest_point(nav_agent.get_navigation_map(), attempt_pos)
	nav_agent.target_position = destination
	nav_agent.get_next_path_position()
	path = nav_agent.get_current_navigation_path()
	set_path(path)
	path_follow.progress = 0.0


func set_path(new_path: PackedVector3Array):
	old_path = path
	path = new_path
	path_3d.curve.clear_points()
	line_renderer.points = Array(new_path)
	for point: Vector3 in path:
		path_3d.curve.add_point(point)
	path_3d.curve.get_baked_length()


func _update_position():
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
	diff.y = -0.0001
	var collision = move_and_collide(diff)
	return diff


func _process_movement(delta):
	velocity.y -= gravity*delta
	move_and_slide()
	

func _on_normal_state_started():
	if state in [State.NONE, State.AIM]:
		state = State.WALK
		animation_player.play(&"Walk")
		start_path()
	elif state == State.DEAD:
		animation_player.speed_scale = randf_range(0.8,1.3)


func _on_slowed_state_started():
	if state == State.WALK:
		animation_player.stop()
		animation_player.play(&"Shoot")
		animation_player.speed_scale = 0.0
		state = State.AIM


func _on_fast_forward_state_started():
	await TimeManager.bell_rung
	start_path()
	


func _on_hitbox_got_hit() -> void:
	hit()


func _on_enemy_shoot_state_started():
	if state != State.DEAD:
		shoot()


func shoot():
	animation_player.speed_scale = 1.0/Engine.time_scale
	shoot_player.play()
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var params := PhysicsRayQueryParameters3D.new()
	params.from = gun.global_position
	params.to = Player.instance.global_position + Vector3.UP*1.5
	var result: Dictionary = space_state.intersect_ray(params)
	if result.size() > 0:
		var collider: Node = result["collider"]
		if collider is Player:
			collider.hit()


func _on_player_revived():
	if state == State.DEAD: return
	animation_player.play(&"Walk")
	state = State.WALK
	set_path(old_path)
