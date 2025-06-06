class_name Enemy
extends CharacterBody3D


enum State {
	NONE,
	WALK,
	FASTFORWARD,
	AIM,
	DEAD
}


@export var animation_player: AnimationPlayer
@export var nav_agent: NavigationAgent3D
@export var path_3d: Path3D
@export var path_follow: PathFollow3D
@export var gravity: float = 9.0
@export var line_renderer: LineRenderer


var state: State = State.NONE
var path: PackedVector3Array
var current_path_percentage: float = 0.0
var current_path_index: int = 0
var full_path_distance: float


func _ready():
	TimeManager.normal_state_started.connect(_on_normal_state_started)
	TimeManager.slowed_state_started.connect(_on_slowed_state_started)


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
	rotate_to_player()
	state = State.DEAD
	animation_player.play(&"DIEE")


func rotate_to_player():
	look_at(Player.instance.global_position)
	rotation.x = 0
	rotation.z = 0


func start_path(destination: Vector3):
	path_3d.curve.clear_points()
	nav_agent.target_position = destination
	nav_agent.get_next_path_position()
	path = nav_agent.get_current_navigation_path()
	line_renderer.points = Array(path)
	print(path)
	for point: Vector3 in path:
		path_3d.curve.add_point(point)
	path_3d.curve.get_baked_length()
	path_follow.progress = 0.0
		

func _update_position():
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
		var attempt_pos: Vector3 = global_position + Vector3.FORWARD.rotated(Vector3.UP, randf()*TAU)*10.0
		var destination: Vector3 = \
			NavigationServer3D.map_get_closest_point(nav_agent.get_navigation_map(), attempt_pos)
		start_path(destination)


func _on_slowed_state_started():
	if state == State.WALK:
		animation_player.play(&"Shoot")
		state = State.AIM
