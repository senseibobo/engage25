class_name SceneManager
extends Control


static var instance: SceneManager

@export var dialogue_label: Dialogue

@export var r1: ColorRect
@export var r2: ColorRect

var tween: Tween


func _enter_tree():
	instance = self

func _ready():
	TimeManager.bell_rung.connect(add_borders)
	TimeManager.normal_state_started.connect(remove_borders)


func add_borders():
	if tween and tween.is_running(): tween.kill()
	tween = create_tween().set_parallel().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT).set_ignore_time_scale()
	tween.tween_property(r1, "custom_minimum_size:y", 100.0, 1.4)
	tween.tween_property(r2, "custom_minimum_size:y", 100.0, 1.4)


func remove_borders():
	if tween and tween.is_running(): tween.kill()
	tween = create_tween().set_parallel().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT).set_ignore_time_scale()
	tween.tween_property(r1, "custom_minimum_size:y", 0, 0.6)
	tween.tween_property(r2, "custom_minimum_size:y", 0, 0.6)
	

func show_message(message: String):
	dialogue_label.show_message(message)
	
