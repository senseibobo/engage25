class_name Impact
extends Node3D


func _ready():
	get_tree().create_timer(0.2, false).timeout.connect(queue_free)
