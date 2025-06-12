class_name MusicPlayer
extends AudioStreamPlayer


var target_volume_db: float
var music_pos_offset: float = 0.0


func _ready() -> void:
	TimeManager.slowed_state_started.connect(volume_down)
	TimeManager.slowed_state_ended.connect(volume_up)
	TimeManager.rewind_state_started.connect(volume_down)
	TimeManager.rewind_finished.connect(volume_up)
	TimeManager.fast_forward_state_started.connect(volume_down)
	TimeManager.fast_forward_state_ended.connect(volume_up)
	TimeManager.tick.connect(update_music_pos)
	TimeManager.game_over.connect(volume_down)
	TimeManager.started_restarting.connect(volume_down)
	target_volume_db = volume_db


func start_music():
	await TimeManager.tick
	music_pos_offset = TimeManager.time_passed
	play()
	update_music_pos()


func update_music_pos():
	seek(fmod(TimeManager.time_passed-music_pos_offset,stream.get_length()))


func volume_up():
	update_music_pos()
	target_volume_db = 20.0

func volume_down():
	target_volume_db = -80.0


func _process(delta):
	volume_db = lerp(volume_db, target_volume_db, 10*delta)
