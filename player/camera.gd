extends Camera3D

var amount : float
var trauma : float

func _process(delta: float) -> void:
	if(trauma > 0.0):
		shake()
		trauma = max(trauma-0.8*delta/Engine.time_scale, 0.0)

func add_trauma():
	trauma = 0.05

func shake():
	amount = trauma
	h_offset = amount * -1
	v_offset = amount * -1
