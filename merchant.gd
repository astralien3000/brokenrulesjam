class_name Merchant extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 10.0

@export var weight: float = 5.0

@onready var body_shape: CollisionShape3D = $BodyShape

@onready var dialog: Label3D = $BodyShape/Dialog
@onready var dialog_timer: Timer = $BodyShape/Dialog/Timer

@export var zone_map: Map
@export var zone_origin: Vector3i
@export var zone_size: Vector3i

@export var block_library: MeshLibrary
var block: Dictionary[String, int]

@export var required_block_name = "Metal"
@export var required_block_count = 1

@export var reward: int = 2

@export_multiline var quest_dialog: String = ""
@export_multiline var reward_dialog: String = ""
@export_multiline var aftermath_dialog: String = ""


func _ready():
	for i in block_library.get_item_list():
		block[block_library.get_item_name(i)] = i

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * weight * delta
	move_and_slide()

func block_count():
	var ret = 0
	var zone_begin = zone_origin
	var zone_end = zone_origin + zone_size
	for x in range(zone_begin.x, zone_end.x):
		for y in range(zone_begin.y, zone_end.y):
			for z in range(zone_begin.z, zone_end.z):
				if zone_map.get_block(Vector3i(x, y, z)) == block[required_block_name]:
					ret += 1
	return ret

# for debug
func fill_zone(block_id):
	var zone_begin = zone_origin
	var zone_end = zone_origin + zone_size
	for x in range(zone_begin.x, zone_end.x):
		for y in range(zone_begin.y, zone_end.y):
			for z in range(zone_begin.z, zone_end.z):
				zone_map.set_block(Vector3i(x, y, z), block_id)
	

func fill_platform():
	var zone_begin = zone_origin
	var zone_end = zone_origin + zone_size
	var y = zone_origin.y - 1
	for x in range(zone_begin.x, zone_end.x):
		for z in range(zone_begin.z, zone_end.z):
			zone_map.set_block(Vector3i(x, y, z), block["Wood"])
	

func interact(agent: Player):
	if block_count() < required_block_count:
		say(quest_dialog)
		# fill platform
		fill_platform()
	if block_count() >= required_block_count:
		if reward:
			say(reward_dialog)
			agent.coins += reward
			reward = 0
		else:
			say(aftermath_dialog)

func pull(agent: Player, cast: RayCast3D):
	interact(agent)

func push(agent: Player, cast: RayCast3D):
	interact(agent)

func say(text: String):
	dialog.text = text
	dialog_timer.timeout.connect(
		func():
			dialog.text = ""
	)
	dialog_timer.start()
