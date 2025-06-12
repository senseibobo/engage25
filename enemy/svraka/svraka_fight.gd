class_name SvrakaFight
extends Node3D


@export var svraka_enemy: SvrakaEnemy
@export var trigger_area: Area3D


func trigger_fight():
	svraka_enemy.show_message("And here comes our criminal.")
	svraka_enemy.start_fight()
	

func _on_svraka_trigger_area_body_entered(body: Node3D) -> void:
	if body is Player:
		trigger_fight()
		trigger_area.queue_free()
