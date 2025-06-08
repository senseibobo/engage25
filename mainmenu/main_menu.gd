extends Node3D


var intro_done: bool = false
@export var press_any_key_label: Label
var transitioning: bool = false


func _ready():
	press_any_key_label.modulate.a = 0.0


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://world.tscn")
	

func _on_button_2_pressed() -> void:
	get_tree().quit()


func _on_path_follow_3d_intro_done() -> void:
	if intro_done: return
	intro_done = true
	press_any_key_label.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(press_any_key_label, "modulate:a", 1.0, 1.0)
	

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		transitioning = true
		Transition.transition_to(preload("res://global/scene_manager/scene_manager.tscn"))
