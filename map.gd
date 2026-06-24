class_name Map extends GridMap

func pull(agent: Player, cast: RayCast3D):
	var cell_pos_approx : Vector3 = to_local(
		cast.get_collision_point() -
		0.1 * cast.get_collision_normal()
	)
	var cell_pos = Vector3i(
		floor(cell_pos_approx.x),
		floor(cell_pos_approx.y),
		floor(cell_pos_approx.z),
	)
	var block_id = get_cell_item(cell_pos)
	set_cell_item(cell_pos, -1)
	agent.set_block(block_id)

func push(agent: Player, cast: RayCast3D):
	var cell_pos_approx : Vector3 = to_local(
		cast.get_collision_point() +
		0.1 * cast.get_collision_normal()
	)
	var cell_pos = Vector3i(
		floor(cell_pos_approx.x),
		floor(cell_pos_approx.y),
		floor(cell_pos_approx.z),
	)
	var block_id = agent.get_block()
	agent.clear_block()
	set_cell_item(cell_pos, block_id)
	
