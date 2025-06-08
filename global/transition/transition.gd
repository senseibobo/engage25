extends CanvasLayer


signal transitioned


@export var transition_rect: ColorRect


var tween: Tween


func _ready():
	transition_rect.color.a = 0.0


func transition_to(scene: PackedScene):
	if tween and tween.is_running(): tween.kill()
	tween = create_tween().set_ignore_time_scale()
	tween.tween_property(transition_rect, "color:a", 1.0, 0.5)
	tween.tween_callback(transitioned.emit)
	tween.tween_callback(switch_scene.bind(scene))
	tween.tween_property(transition_rect, "color:a", 0.0, 0.5)


func switch_scene(scene: PackedScene):
	get_tree().change_scene_to_packed(scene)
