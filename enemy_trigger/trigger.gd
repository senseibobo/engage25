extends Area3D
class_name TriggerEnemy

@export var enemies: Array[Enemy]

func _ready() -> void:
	connect("body_entered", activate_enemies)

func activate_enemies(body):
	if body is Player:
		queue_free()
		for enemy in enemies:
			enemy.activate()
