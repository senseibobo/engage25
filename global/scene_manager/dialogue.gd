class_name Dialogue
extends Label



@export var animation_player: AnimationPlayer
@export var kaakaa_player: AudioStreamPlayer


var timer: float = 0.0
var shown: bool = false


func _process(delta):
	animation_player.speed_scale = 1/Engine.time_scale
	if shown:
		timer -= delta/Engine.time_scale
		if timer <= 0:
			shown = false
			animation_player.play_backwards(&"appear")


func show_message(message: String):
	animation_player.play(&"appear")
	kaakaa_player.play()
	text = message
	shown = true
	timer = 4.0
