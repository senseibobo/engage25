class_name SceneManager
extends Control


@export var r1: ColorRect
@export var r2: ColorRect



func _ready():
	get_tree().create_timer(2.0).timeout.connect(add_borders)


func add_borders():
	print("adding borders")
	var tween: Tween = create_tween().set_parallel().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(r1, "custom_minimum_size:y", 130.0, 1.0)
	tween.tween_property(r2, "custom_minimum_size:y", 130.0, 1.0)
