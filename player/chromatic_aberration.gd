class_name ChromaticAberrationFilter
extends ColorRect


var spread_percent: float:
	set(value):
		spread_percent = value
		if is_instance_valid(material):
			material.set_shader_parameter(&"spread", value/100.0)
	get:
		return spread_percent

var target_spread_percent: float = 0.0



func _ready():
	TimeManager.enemy_killed.connect(add)
	TimeManager.slowed_state_ended.connect(reset)
	target_spread_percent = 0.0
	self.spread_percent = 0.0


func _process(delta):
	self.spread_percent = lerp(self.spread_percent, target_spread_percent, 2*delta/Engine.time_scale)


func add():
	target_spread_percent += 1.0


func reset():
	target_spread_percent = 0.0
