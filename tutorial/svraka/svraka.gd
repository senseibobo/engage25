extends Node3D

@export var anim_player: AnimationPlayer

func play_talk():
	anim_player.stop()
	anim_player.play(&"Talk")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if(anim_name == &"Talk"):
		anim_player.stop()
		anim_player.play(&"Idle")
