extends AudioStreamPlayer

func _ready() -> void:
	TimeManager.rewind_state_started.connect(start_music)
	TimeManager.rewind_finished.connect(stop_music)
	TimeManager.fast_forward_state_started.connect(forward)
	TimeManager.fast_forward_state_ended.connect(stop_forward)

func start_music():
	volume_db = -24.0

func stop_music():
	volume_db = 24.0

func forward():
	volume_db = -24.0

func stop_forward():
	volume_db = 24.0
