class_name Gun
extends Node3D


@export var shoot_position: Marker3D
@export var animation_player: AnimationPlayer
@export var crosshair: Control
@export var barrel: Node3D

@export var cock_player: AudioStreamPlayer
@export var spin_player: AudioStreamPlayer
@export var shoot_player: AudioStreamPlayer

@export var shot_instance_scene: PackedScene

var target_point: Vector3
var free_aim: bool = false
var cock_timer: float = 0.0
var cocking: bool = false
var reloading: bool = false


func _ready():
	TimeManager.normal_state_started.connect(stop_free_aim)
	TimeManager.slowed_state_started.connect(start_free_aim)


func _process(delta):
	if reloading: 
		rotation = Vector3()
		return
	aim_at_screen_point(get_viewport().get_mouse_position())
	cock_timer -= delta/Engine.time_scale
	if cocking and cock_timer <= 0:
		cocking = false
		cock_player.play()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if free_aim: get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT and free_aim:
			shoot()



func aim_at_screen_point(screen_point: Vector2):
	crosshair.position = screen_point
	var target_point_found: bool = false
	
	var camera: Camera3D = get_viewport().get_camera_3d()
	
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var params := PhysicsRayQueryParameters3D.new()
	var camera_normal: Vector3 = camera.project_ray_normal(screen_point)
	params.from = camera.project_ray_origin(screen_point)
	params.to = params.from + camera_normal*10000.0
	
	var result: Dictionary = space_state.intersect_ray(params)
	if "position" in result:
		target_point = result["position"]
		target_point_found = true
	else:
		var plane := Plane(camera_normal, params.from + camera_normal*40.0)
		var point = plane.intersects_ray(params.from, camera_normal)
		if point:
			target_point = point
			target_point_found = true
	if target_point_found:
		look_at(target_point)


func shoot():
	cock_timer = 0.12
	cocking = true
	shoot_player.play()
	var tween: Tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(barrel, "rotation:x", barrel.rotation.x + PI/3, 0.25*Engine.time_scale)
	animation_player.stop()
	animation_player.play(&"shoot")
	animation_player.speed_scale = 1.0/Engine.time_scale
	var pos: Vector3 = shoot_position.global_position
	var shot_instance: Shot = shot_instance_scene.instantiate()
	get_tree().current_scene.add_child(shot_instance)
	shot_instance.setup(pos, target_point)


func start_free_aim():
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
	Input.warp_mouse(get_window().size/2.0)
	free_aim = true


func stop_free_aim():
	barrel.rotation.x = 0.0
	Input.warp_mouse(get_window().size/2.0)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	free_aim = false
	print("batonga")
	animation_player.speed_scale = 1.0
	animation_player.stop()
	animation_player.play(&"reload")
	aim_at_screen_point(get_viewport().size/2.0)
