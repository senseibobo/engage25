class_name BlackAndWhiteFilter
extends ColorRect


@export var red_enemies_viewport_container: SubViewportContainer
@export var red_camera: Camera3D

var tween: Tween
var strength: float:
	set(value):
		strength = value
		if is_instance_valid(red_enemies_viewport_container):
			red_enemies_viewport_container.material.set_shader_parameter(&"alpha", value)
			red_enemies_viewport_container.modulate.a = value
		if is_instance_valid(material):
			material.set_shader_parameter(&"strength", strength)
	get:
		return strength


func _ready():
	self.strength = 0.0


func _process(delta):
	var main_camera: Camera3D = get_viewport().get_camera_3d()
	red_camera.global_transform = main_camera.global_transform
	red_camera.h_offset = main_camera.h_offset
	red_camera.v_offset = main_camera.v_offset
	red_camera.fov = main_camera.fov


func fade_in():
	if tween and tween.is_running(): tween.kill()
	tween = create_tween().set_ignore_time_scale()
	tween.tween_property(self, "strength", 1.0, 0.6)

func fade_out():
	if tween and tween.is_running(): tween.kill()
	tween = create_tween().set_ignore_time_scale()
	tween.tween_property(self, "strength", 0.0, 0.6)

	
