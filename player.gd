class_name Player extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 10.0

@export var mouse_sensitivity: float = 0.002
@export var weight: float = 5.0

@export var mesh_library: MeshLibrary

@onready var camera_y_root: Node3D = $CameraYRoot
@onready var camera_x_root: Node3D = $CameraYRoot/CameraXRoot
@onready var camera: Camera3D = $CameraYRoot/CameraXRoot/Camera3D
@onready var body_shape: CollisionShape3D = $BodyShape

@onready var interaction_cast: RayCast3D = $CameraYRoot/CameraXRoot/Camera3D/RayCast3D
@onready var slot: Node3D = $BodyShape/Slot

@onready var jump_detector: Area3D = $BodyShape/JumpDetector

var block : int = -1

func _input(event: InputEvent):
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			camera_y_root.rotate_y(-event.relative.x * mouse_sensitivity)
			camera_x_root.rotate_x(-event.relative.y * mouse_sensitivity)
			camera_x_root.rotation.x = clamp(camera_x_root.rotation.x, deg_to_rad(-80), deg_to_rad(45))

func _physics_process(delta: float) -> void:
	# handle mouse capture
	if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
		if Input.is_action_just_pressed("interact"):
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		if Input.is_action_just_pressed("escape"):
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		if Input.is_action_just_pressed("interact"):
			if not has_block():
				if interaction_cast.is_colliding():
					var interactor: Node3D = interaction_cast.get_collider()
					if interactor.has_method("pull"):
						interactor.pull(
							self,
							interaction_cast,
						)
			else:
				if interaction_cast.is_colliding():
					var interactor: Node3D = interaction_cast.get_collider()
					if interactor.has_method("push"):
						interactor.push(
							self,
							interaction_cast,
						)
					

	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * weight * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (camera_y_root.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		if jump_detector.has_overlapping_bodies() and is_on_floor():
			velocity.y = JUMP_VELOCITY
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		body_shape.rotation.y = atan2(-direction.x, -direction.z)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

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
