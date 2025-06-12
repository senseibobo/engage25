extends Node3D

signal all_bottles_shot
signal svraka_shot


@export var positions: Array[Vector3]
@export_multiline var dialogues: Array[String]

@export var bottle_scene: PackedScene
@export var dialogue: Label
@export var audio_player: AudioStreamPlayer
@export var animation_player: AnimationPlayer
@export var svraka: Node3D

var timer: float = 0.0

var count: int
var iterator: int = 0


func _ready() -> void:
	svraka.shot.connect(show_dialogue.bind(svraka.shoot_dialogue))
	await get_tree().process_frame
	await get_tree().process_frame
	spawn.call_deferred()
	show_dialogue("Dumb human.")
	await TimeManager.bell_rung
	show_dialogue("Every 5 seconds, the bell rings and you can shoot.")
	await all_bottles_shot
	show_dialogue("Great. You can hit a bottle. Try to fast forward with E.")
	await TimeManager.fast_forward_state_ended
	show_dialogue("You can rewind by using Q.")
	await TimeManager.rewind_state_started
	await TimeManager.rewind_finished
	show_dialogue("Follow the criminal town signs and get those idiots. Good luck.")


func spawn():
	count = positions.size()
	for position in positions:
		var bottle = bottle_scene.instantiate()
		bottle.connect(&"destroyed_bottle", _on_destroy_bottle)
		add_child(bottle)
		bottle.position = position


func _process(delta):
	var old_timer = timer
	timer -= delta/Engine.time_scale
	if old_timer > 0 and timer < 0:
		hidee()


func show_dialogue(text):
	SceneManager.instance.show_message(text)
	svraka.play_talk()


func _on_destroy_bottle():
	count -= 1
	if count == 0:
		all_bottles_shot.emit()
		get_tree().create_timer(0.2).timeout.connect(spawn)


func hidee():
	SceneManager.instance.dialogue_animation.play_backwards(&"appear")
