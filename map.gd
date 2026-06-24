class_name Map extends Node3D

const CHUNK_SIZE = 16

@export var noise: FastNoiseLite
@export var mesh_library: MeshLibrary

@export var chunk_tscn: PackedScene

var chunks: Dictionary[Vector3i, Chunk] = {}

func _ready():
	generate_around(0,0,0)

func generate_around(cx, cy, cz):
	WorkerThreadPool.add_task(
		func():
			for dx in [0,-1,1,-2,2]:
				for dz in [0,-1,1,-2,2]:
					for dy in [-1,0,1]:
						generate_chunk(cx + dx, cy + dy, cz + dz)
	)
	

func generate_chunk(cx, cy, cz):
	var chunk = chunk_tscn.instantiate()
	if Vector3i(cx, cy, cz) in chunks.keys():
		return
	chunks[Vector3i(cx, cy, cz)] = chunk
	for bx in range(0, CHUNK_SIZE):
		var x = cx * CHUNK_SIZE + bx
		for bz in range(0, CHUNK_SIZE):
			var z = cz * CHUNK_SIZE + bz
			var height = noise.get_noise_2d(x, z) * 10
			for by in range(0, CHUNK_SIZE):
				var y = cy * CHUNK_SIZE + by
				if y < height:
					chunk.set_cell_item(Vector3i(bx, by, bz), 0)
	chunk.position.x = cx * CHUNK_SIZE
	chunk.position.y = cy * CHUNK_SIZE
	chunk.position.z = cz * CHUNK_SIZE
	chunk.map = self
	add_child.call_deferred(chunk)

func chunk_pos(pos: Vector3):
	var cell_pos = Vector3i(
		floor(pos.x), floor(pos.y), floor(pos.z),
	)
	return Vector3i(
		floor(float(cell_pos.x) / CHUNK_SIZE),
		floor(float(cell_pos.y) / CHUNK_SIZE),
		floor(float(cell_pos.z) / CHUNK_SIZE),
	)

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
	var chunk_pos = Vector3i(
		floor(float(cell_pos.x) / CHUNK_SIZE),
		floor(float(cell_pos.y) / CHUNK_SIZE),
		floor(float(cell_pos.z) / CHUNK_SIZE),
	)
	var block_pos = Vector3i(
		(cell_pos.x % CHUNK_SIZE + CHUNK_SIZE) % CHUNK_SIZE,
		(cell_pos.y % CHUNK_SIZE + CHUNK_SIZE) % CHUNK_SIZE,
		(cell_pos.z % CHUNK_SIZE + CHUNK_SIZE) % CHUNK_SIZE,
	)
	var chunk = chunks[chunk_pos]
	var block_id = chunk.get_cell_item(block_pos)
	chunk.set_cell_item(block_pos, -1)
	print(chunk_pos, block_pos)
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
	var chunk_pos = Vector3i(
		floor(float(cell_pos.x) / CHUNK_SIZE),
		floor(float(cell_pos.y) / CHUNK_SIZE),
		floor(float(cell_pos.z) / CHUNK_SIZE),
	)
	var block_pos = Vector3i(
		(cell_pos.x % CHUNK_SIZE + CHUNK_SIZE) % CHUNK_SIZE,
		(cell_pos.y % CHUNK_SIZE + CHUNK_SIZE) % CHUNK_SIZE,
		(cell_pos.z % CHUNK_SIZE + CHUNK_SIZE) % CHUNK_SIZE,
	)
	var chunk = chunks[chunk_pos]
	var block_id = agent.get_block()
	agent.clear_block()
	chunk.set_cell_item(block_pos, block_id)
