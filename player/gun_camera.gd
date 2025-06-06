class_name GunCamera
extends Camera3D


@export var main_camera: Camera3D


func _process(delta):
	global_transform = main_camera.global_transform
	h_offset = main_camera.h_offset
	v_offset = main_camera.v_offset
