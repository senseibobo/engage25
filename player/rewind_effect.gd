class_name RewindEffect
extends TextureRect


@export var camera: Camera3D


func _ready():
	TimeManager.connect("rewind_state_started", start)
	TimeManager.connect("rewind_finished", stop)



func start():
	var tween = create_tween().set_ignore_time_scale(true).set_parallel().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tween.tween_property(camera, "fov", 60, 2.0)
	tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 1.0), 2.0)


func stop():
	var tween = create_tween().set_ignore_time_scale(true).set_parallel().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_property(camera, "fov", 75, 0.5)
	tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 0.0), 0.5)
