class_name Chunk extends GridMap

var map : Map

func pull(agent: Player, cast: RayCast3D):
	map.pull(agent, cast)

func push(agent: Player, cast: RayCast3D):
	map.push(agent, cast)
