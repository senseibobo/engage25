class_name Player
extends CharacterBody3D


@export var camera: Camera3D
@export var movement_speed: float = 3.0
@export var gravity: float = 9.0


func _ready():
	pass#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _process(delta: float) -> void:
	_process_walking(delta)


func _process_walking(delta: float):
	
	var input: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var move_dir: Vector3 = (Vector3(1,0,1)*(basis.z * input.y + basis.x * input.x)).normalized()
	var velocity_xz: Vector3 = move_dir*movement_speed
	
	velocity.x = velocity_xz.x
	velocity.z = velocity_xz.z
	velocity.y -= gravity * delta
	
	move_and_slide()


func _unhandled_input(event: InputEvent):
	if event is InputEventMouseMotion:
		camera.rotation_degrees.x -= event.relative.y/100.0
		camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, -80.0, 80.0)
		rotation_degrees.y -= event.relative.x/100.0
		
