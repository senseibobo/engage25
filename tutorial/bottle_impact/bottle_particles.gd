extends GPUParticles3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	speed_scale = 1.0/Engine.time_scale
