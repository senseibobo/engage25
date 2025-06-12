class_name Crystal
extends Node3D


signal exploded


@export var explode_particles: GPUParticles3D
@export var crystal_mesh: MeshInstance3D
@export var hittable: bool = false
@export var hitbox: Hitbox
@export var explode_player: AudioStreamPlayer3D


var exploding: bool = false



func _ready():
	if not hittable:
		hitbox.queue_free()
	else:
		crystal_mesh.layers |= 4


func explode(delete: bool = true):
	explode_player.play()
	exploded.emit()
	exploding = true
	crystal_mesh.visible = false
	explode_particles.emitting = true
	if delete:
		await get_tree().create_timer(1.0,false,false,true).timeout
		queue_free()


func _process(delta):
	if exploding:
		explode_particles.speed_scale = 1.0/Engine.time_scale


func _on_hitbox_got_hit() -> void:
	hitbox.queue_free()
	explode()
