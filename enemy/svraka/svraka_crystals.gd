class_name SvrakaCrystals
extends Node3D


signal all_crystals_destroyed


const CRYSTAL_COUNT: int = 6


@export var crystal_scene: PackedScene


var crystals: Array[Crystal] = []
var rotation_offset: float = 0.0
var crystals_left: int = 0


func _ready():
	TimeManager.queue_state_started.connect(_on_queue_state_started)
	create_crystals()


func _on_queue_state_started():
	for crystal: Crystal in crystals:
		if is_instance_valid(crystal):
			crystal.queue_free()
	crystals.clear()
	create_crystals()


func create_crystals():
	crystals_left = CRYSTAL_COUNT
	for i in CRYSTAL_COUNT:
		var crystal: Crystal = crystal_scene.instantiate() 
		crystal.hittable = true
		crystal.scale *= 25.0
		crystal.top_level = true
		crystal.exploded.connect(_on_crystal_exploded)
		crystals.append(crystal)
		add_child(crystal)
		crystal.global_position = global_position


func _on_crystal_exploded():
	crystals_left -= 1
	print(crystals_left)
	if crystals_left == 0:
		all_crystals_destroyed.emit()


func _process(delta):
	var scaled_delta: float = delta/Engine.time_scale
	rotation_offset += scaled_delta
	var i: float = 0.0
	for crystal: Crystal in crystals:
		if crystal == null:
			i += 1.0
			continue
		var camera: Camera3D = get_viewport().get_camera_3d()
		var camera_distance: float = camera.global_position.distance_to(global_position)
		var distance: float = 4.0
		var right: Vector3 = camera.global_basis.x.normalized()
		var forward: Vector3 = -camera.global_basis.z.normalized()
		var offset: Vector3 = distance*right.rotated(forward, rotation_offset+TAU*i/float(CRYSTAL_COUNT))
		var target_position: Vector3 = global_position + offset
		crystal.global_position = lerp(crystal.global_position, target_position, 4.0*scaled_delta)
		#crystal.scale = Vector3.ONE*camera_distance
		i += 1.0



		
