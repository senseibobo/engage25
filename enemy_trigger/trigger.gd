extends Area3D
class_name TriggerEnemy

@export var enemies: Array[Enemy]
@export var audio_player: AudioStreamPlayer

func _ready() -> void:
	collision_mask = 8
	collision_layer = 8
	connect("body_entered", activate_enemies)


func activate_enemies(body):
	if body is Player:
		if audio_player != null: audio_player.play()
		queue_free()
		for enemy in enemies:
			enemy.activate()
