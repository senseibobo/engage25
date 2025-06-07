class_name Gun
extends Node3D


@export var shoot_position: Marker3D
@export var animation_player: AnimationPlayer
@export var crosshair: Control
@export var barrel: Node3D
@export var shake_camera: Camera3D

@export var cock_player: AudioStreamPlayer
@export var spin_player: AudioStreamPlayer
@export var shoot_player: AudioStreamPlayer

@export var shot_instance_scene: PackedScene

var bullets_left: int = 6
var target_point: Vector3
var free_aim: bool = false
var cock_timer: float = 0.0
var cocking: bool = false
var reloading: bool = false
var mouse_move: float


func _ready():
	crosshair.visible = false
	TimeManager.normal_state_started.connect(stop_free_aim)
	TimeManager.slowed_state_started.connect(start_free_aim)
	TimeManager.player_revived.connect(stop_free_aim)


func _process(delta):
	animation_player.speed_scale = 1.0/Engine.time_scale
	if Player.instance.dead:
		rotation = Vector3(PI/2.0,0,0)
		return
	if reloading: 
		rotation = Vector3()
		return
	if free_aim:
		aim_at_screen_point(get_viewport().get_mouse_position())
	else:
		rotation = Vector3(-PI*0.35, 0.0,0.0)
	if not free_aim:
		sway(delta)
	cock_timer -= delta/Engine.time_scale
	if cocking and cock_timer <= 0:
		cocking = false
		cock_player.play()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_move = -event.relative.x
		if free_aim: get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT and free_aim and bullets_left > 0:
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
	params.collide_with_areas = true
	params.collide_with_bodies = true
	
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
	bullets_left -= 1
	cock_timer = 0.12
	cocking = true
	shoot_player.play()
	var tween: Tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(barrel, "rotation:x", barrel.rotation.x + PI/3, 0.25*Engine.time_scale)
	animation_player.stop()
	animation_player.play(&"shoot")
	animation_player.speed_scale = 1.0/Engine.time_scale
	shake_camera.add_trauma()
	var pos: Vector3 = shoot_position.global_position
	
	var shot_instance: Shot = shot_instance_scene.instantiate()
	get_tree().current_scene.add_child(shot_instance)
	
	shot_instance.setup(pos, target_point)


func start_free_aim():
	crosshair.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
	Input.warp_mouse(get_window().size/2.0)
	free_aim = true


func stop_free_aim():
	crosshair.visible = false
	barrel.rotation.x = 0.0
	Input.warp_mouse(get_window().size/2.0)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	free_aim = false
	print("batonga")
	if bullets_left < 6:
		animation_player.speed_scale = 1.0
		animation_player.stop()
		animation_player.play(&"reload")
		bullets_left = 6
	aim_at_screen_point(get_viewport().size/2.0)

func sway(delta: float):
	if(mouse_move > 2):
		position = position.lerp(Vector3(0.3, -0.232, -0.518), 5.0*delta)
	elif(mouse_move < -2):
		position = position.lerp(Vector3(0.5, -0.232, -0.518), 5.0*delta)
	else:
		position = position.lerp(Vector3(0.402, -0.232, -0.518), 5.0*delta)
