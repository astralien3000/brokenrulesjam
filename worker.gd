class_name Worker extends CharacterBody3D


const SPEED = 7.0
const JUMP_VELOCITY = 10.0

@export var weight: float = 5.0

@export var mesh_library: MeshLibrary

@onready var body_shape: CollisionShape3D = $BodyShape

#@onready var interaction_cast: RayCast3D = $CameraYRoot/CameraXRoot/Camera3D/RayCast3D
@onready var slot: Node3D = $BodyShape/Slot
@onready var dialog: Label3D = $BodyShape/Dialog
@onready var dialog_timer: Timer = $BodyShape/Dialog/Timer

@onready var jump_detector: Area3D = $BodyShape/JumpDetector

@export var player: Player = null
@export var salary: int = 2

var block : int = -1

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * weight * delta

	if player != null:
		var target_vec := player.position - position
		var direction := target_vec.normalized()
		var speed = SPEED * (1 - 1/target_vec.length())
		if target_vec.length() > 3.0:
			if jump_detector.has_overlapping_bodies() and is_on_floor():
				velocity.y = JUMP_VELOCITY
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
			body_shape.rotation.y = atan2(-direction.x, -direction.z)
		else:
			velocity.x = 0.0
			velocity.z = 0.0

	move_and_slide()

func has_block():
	return block != -1

func set_block(id: int):
	block = id
	var node = MeshInstance3D.new()
	node.mesh = mesh_library.get_item_mesh(id)
	slot.add_child(node)

func get_block() -> int:
	return block

func clear_block():
	block = -1
	for node in slot.get_children():
		slot.remove_child(node)

func pull(agent: Player, cast: RayCast3D):
	if player == null:
		if agent.coins >= salary:
			agent.coins -= salary
			player = agent
			say("I will follow you")
		else:
			say("You need " + str(salary) + " coins to hire me")
	elif has_block():
		var block_id = get_block()
		clear_block()
		agent.set_block(block_id)

func push(agent: Player, cast: RayCast3D):
	if agent.has_block() and not has_block():
		var block_id = agent.get_block()
		agent.clear_block()
		set_block(block_id)

func say(text: String):
	dialog.text = text
	dialog_timer.timeout.connect(
		func():
			dialog.text = ""
	)
	dialog_timer.start()
