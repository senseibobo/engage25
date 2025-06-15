class_name Tumbleweed
extends RigidBody3D


@export var sprite: Sprite3D

var rotation_amount: float = 0.0


func _ready():
	apply_central_impulse(10*Vector3.LEFT)


func _physics_process(delta: float) -> void:
	self.rotation = Vector3()
	apply_central_force(10*Vector3.LEFT*delta)
	sprite.look_at(Player.instance.global_position)
	rotation_amount += delta*linear_velocity.length()
	var rotation_axis: Vector3 = Vector3.LEFT
	sprite.rotate(rotation_axis, rotation_amount)
