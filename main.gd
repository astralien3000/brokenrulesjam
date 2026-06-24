extends Node

@onready var player = $Node3D/CharacterBody3D
@onready var map = $Node3D/Map


func _on_timer_timeout() -> void:
	var cpos = map.chunk_pos(player.position)
	map.generate_around(
		cpos.x, cpos.y, cpos.z
	)
