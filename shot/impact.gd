class_name Impact
extends Node3D

@export var anim_player: AnimationPlayer

func _ready():
	anim_player.speed_scale = 1.0/Engine.time_scale
	get_tree().create_timer(0.2, false, false, true).timeout.connect(queue_free)
