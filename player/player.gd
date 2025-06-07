class_name Player
extends CharacterBody3D


static var instance: Player


@export var camera: Camera3D
@export var movement_speed: float = 3.0
@export var gravity: float = 9.0
@export var animation_player: AnimationPlayer
@export var black_and_white_filter: BlackAndWhiteFilter
@export var rewind_effect: TextureRect

var dead: bool = false
var distance_traveled: float = 0.0


func _enter_tree():
	instance = self


func _ready():
	TimeManager.connect("slowed_state_started", _turn_filter_on)
	TimeManager.connect("normal_state_started", _turn_filter_off)
	TimeManager.connect("rewind_state_started", _rewind_effect)
	#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _process(delta: float) -> void:
	if dead: return
	_process_walking(delta)


func _process_walking(delta: float):
	
	var input: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var move_dir: Vector3 = (Vector3(1,0,1)*(basis.z * input.y + basis.x * input.x)).normalized()
	var velocity_xz: Vector3 = move_dir*movement_speed
	
	velocity.x = velocity_xz.x
	velocity.z = velocity_xz.z
	velocity.y -= gravity * delta
	
	distance_traveled += (Vector3(1,0,1)*velocity).length()*delta*3.0
	camera.h_offset = sin(distance_traveled)*0.03
	camera.v_offset = cos(distance_traveled*2.0)*0.03
	
	move_and_slide()


func _unhandled_input(event: InputEvent):
	if dead: return
	if event is InputEventMouseMotion:
		camera.rotation_degrees.x -= event.relative.y/20.0
		camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, -80.0, 80.0)
		rotation_degrees.y -= event.relative.x/20.0


func hit():
	if dead: return
	animation_player.play(&"death")
	dead = true
	black_and_white_filter.fade_in()
	Engine.time_scale = 0.01
	animation_player.speed_scale = 1.0/Engine.time_scale

func revive():
	black_and_white_filter.fade_out()
	dead = false
	animation_player.play_backwards(&"death")

func _turn_filter_on():
	black_and_white_filter.fade_in()

func _turn_filter_off():
	black_and_white_filter.fade_out()
	var tween = create_tween().set_ignore_time_scale(true).set_parallel().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_property(camera, "fov", 75, 0.5)
	tween.tween_property(rewind_effect, "modulate", Color(1.0, 1.0, 1.0, 0.0), 0.5)

func _rewind_effect():
	var tween = create_tween().set_ignore_time_scale(true).set_parallel().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tween.tween_property(camera, "fov", 100, 2.0)
	tween.tween_property(rewind_effect, "modulate", Color(1.0, 1.0, 1.0, 1.0), 2.0)
