extends Node

@onready var player = $Node3D/Player
@onready var map = $Node3D/Map

@onready var coin_lbl = $VBoxContainer/Label

func _ready():
	var cpos = map.chunk_pos(player.position)
	map.generate_around(
		cpos.x, cpos.y, cpos.z,
	)

func _on_timer_timeout() -> void:
	var cpos = map.chunk_pos(player.position)
	map.generate_around(
		cpos.x, cpos.y, cpos.z,
	)
	coin_lbl.text = "coins : {0}".format([player.coins])
