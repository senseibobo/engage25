class_name MainMenuCamera
extends PathFollow3D


signal intro_done


func _ready():
	progress_ratio = 0.6
	var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "progress_ratio", 1.0, 3.0)
	tween.tween_callback(intro_done.emit)
