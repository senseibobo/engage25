extends Node3D



func _ready():
	for c in $"MAPA CELA".get_children():
		if c is CollisionShape3D:
			if c.shape is ConcavePolygonShape3D:
				c.shape.backface_collision = true
