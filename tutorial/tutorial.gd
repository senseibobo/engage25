extends Node3D

@export var positions: Array[Vector3]
@export var dialogues: Array[StringName]

@export var bottle_scene: PackedScene
@export var dialogue: Label
@export var audio_player: AudioStreamPlayer
@export var svraka: Node3D

var count: int
var iterator: int = 0

func _ready() -> void:
	spawn()
	next_dialogue()
	count = positions.size()

func spawn():
	for position in positions:
		var bottle = bottle_scene.instantiate()
		bottle.connect(&"destroyed_bottle", _on_destroy_bottle)
		add_child(bottle)
		bottle.position = position

func next_dialogue():
	audio_player.play()
	dialogue.text = dialogues[iterator]
	svraka.play_talk()
	if((iterator+1) == dialogues.size()):
		iterator = 0
	else:
		iterator += 1

func _on_destroy_bottle():
	count -= 1
	if(count == 0):
		next_dialogue()
		get_tree().create_timer(0.2).connect(&"timeout", spawn)
		count = positions.size()
