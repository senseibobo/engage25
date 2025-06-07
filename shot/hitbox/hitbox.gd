class_name Hitbox
extends Area3D


signal got_hit


func _ready():
	collision_layer = 2
	collision_mask = 2


func hit():
	got_hit.emit()
