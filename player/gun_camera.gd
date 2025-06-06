class_name GunCamera
extends Camera3D


@export var main_camera: Camera3D


func _process(delta):
	global_transform = main_camera.global_transform
