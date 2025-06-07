class_name RewindEffect
extends TextureRect


@export var camera: Camera3D
@export var rewind_player: AudioStreamPlayer
@export var forward_player: AudioStreamPlayer


func _ready():
	TimeManager.rewind_state_started.connect(start)
	TimeManager.rewind_finished.connect(stop)
	TimeManager.fast_forward_state_started.connect(forward)
	TimeManager.fast_forward_state_ended.connect(stop_forward)



func start():
	rewind_player.play()
	var tween = create_tween().set_ignore_time_scale(true).set_parallel().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tween.tween_property(camera, "fov", 60, 2.0)
	tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 1.0), 2.0)


func stop():
	var tween = create_tween().set_ignore_time_scale(true).set_parallel().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_property(camera, "fov", 75, 0.5)
	tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 0.0), 0.5)

func forward():
	forward_player.play()
	var tween = create_tween().set_ignore_time_scale(true).set_parallel().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(camera, "fov", 90, 0.5)
	tween.tween_property(self, "modulate", Color(0.8, 1.0, 0.8, 1.0), 0.5)
	
func stop_forward():
	var tween = create_tween().set_ignore_time_scale(true).set_parallel().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_property(camera, "fov", 75, 0.5)
	tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 0.0), 0.5)
