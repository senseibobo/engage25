class_name RewindEffect
extends TextureRect


@export var camera: Camera3D
@export var rewind_player: AudioStreamPlayer
@export var forward_player: AudioStreamPlayer

var fast_forward_tween: Tween
var rewind_tween: Tween


func _ready():
	TimeManager.rewind_state_started.connect(start)
	TimeManager.rewind_finished.connect(stop)
	TimeManager.fast_forward_state_started.connect(forward)
	TimeManager.fast_forward_state_ended.connect(stop_forward)
	TimeManager.started_restarting.connect(start)



func start():
	rewind_player.play()
	if rewind_tween and rewind_tween.is_running(): rewind_tween.kill()
	rewind_tween = create_tween().set_ignore_time_scale(true).set_parallel().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	rewind_tween.tween_property(camera, "fov", 60, 2.0)
	rewind_tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 1.0), 2.0)


func stop():
	if rewind_tween and rewind_tween.is_running(): rewind_tween.kill()
	rewind_tween = create_tween().set_ignore_time_scale(true).set_parallel().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	rewind_tween.tween_property(camera, "fov", 75, 0.5)
	rewind_tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 0.0), 0.5)

func forward():
	forward_player.play()
	if fast_forward_tween and fast_forward_tween.is_running(): fast_forward_tween.kill()
	fast_forward_tween = create_tween().set_ignore_time_scale(true).set_parallel().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	fast_forward_tween.tween_property(camera, "fov", 90, 0.5)
	fast_forward_tween.tween_property(self, "modulate", Color(0.8, 1.0, 0.8, 1.0), 0.5)
	
func stop_forward():
	if fast_forward_tween and fast_forward_tween.is_running(): fast_forward_tween.kill()
	fast_forward_tween = create_tween().set_ignore_time_scale(true).set_parallel().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	fast_forward_tween.tween_property(camera, "fov", 75, 0.5)
	fast_forward_tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 0.0), 0.5)
