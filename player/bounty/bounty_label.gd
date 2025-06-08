class_name BountyLabel
extends Label


@export var amount_label: Label
@export var multiplier_label: Label

var bounty: float = 0.0


var trauma: float = 0.0
var time: float = 0.0
var multiplier: float = 1.0

func _ready():
	multiplier_label.visible = false
	TimeManager.enemy_killed.connect(_on_enemy_killed)
	TimeManager.slowed_state_ended.connect(_on_slowed_state_ended)


func _process(delta):
	time += delta*40.0/Engine.time_scale
	trauma = lerp(trauma, 0.0, 5*delta/Engine.time_scale)
	amount_label.position = Vector2(
		sin(time)*trauma,
		cos(time*2.2)*trauma
	)


func add_trauma():
	trauma += 8.0


func _on_enemy_killed():
	multiplier_label.visible = true
	bounty += 200.0 * multiplier
	multiplier += 1.0
	amount_label.text = str("$", int(bounty))
	multiplier_label.text = str("x", int(multiplier))
	add_trauma()


func _on_slowed_state_ended():
	await get_tree().process_frame
	await get_tree().process_frame
	multiplier = 1.0
	multiplier_label.visible = false
