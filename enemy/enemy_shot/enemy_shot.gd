class_name EnemyShot
extends Node3D


func _ready():
	get_tree().create_timer(0.3, false, false, true).timeout.connect(queue_free)
