class_name World
extends Node3D

@export var sun: DirectionalLight3D


func _enter_tree():
	randomize()




func _process(delta: float) -> void:
	sun.rotation.x = -PI/2.0*TimeManager.time_passed/(TimeManager.high_noon_time)
