class_name BlackAndWhiteFilter
extends ColorRect


var tween: Tween
var strength: float:
	set(value):
		strength = value
		if is_instance_valid(material):
			material.set_shader_parameter(&"strength", strength)
	get:
		return strength


func fade_in():
	print("fade innn")
	if tween and tween.is_running(): tween.kill()
	tween = create_tween().set_ignore_time_scale()
	tween.tween_property(self, "strength", 1.0, 0.6)

func fade_out():
	print("fade outttt")
	if tween and tween.is_running(): tween.kill()
	tween = create_tween().set_ignore_time_scale()
	tween.tween_property(self, "strength", 0.0, 0.6)

	
