extends CharacterBody3D
class_name Player

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@export var head : Node3D
@export var interaction_ray : RayCast3D
@export var mouse_sensitivity : float = 0.1
@export var ui : UI

enum Tool {
	SCANNER,
	SPRAYER,
	PICKER,
	COUNT
}

var kitten_count = 0;
var tardigrade_count = 0;
var current_tool := Tool.SCANNER
var mouse_input : Vector2

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
	if event is not InputEventMouseMotion or Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return
	mouse_input.x += event.relative.x
	mouse_input.y += event.relative.y

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Switch tools
	if Input.is_action_just_pressed("next_tool"):
		current_tool += 1
		if (current_tool as int) >= (Tool.COUNT as int): current_tool = Tool.SCANNER
	elif Input.is_action_just_pressed("prev_tool"):
		current_tool -= 1
		if (current_tool as int) < 0: current_tool = ((Tool.PICKER - 1 )as int) as Tool

	# jump, interact
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	if Input.is_action_just_pressed("use_tool"):
		if interaction_ray.is_colliding():
			var collider = interaction_ray.get_collider()
			if collider is KittenCluster:
				kitten_count += 1
				if (randf()) < 0.2: tardigrade_count += 1
				collider.queue_free()

	ui.update(self)

	# looking, walking
	rotation_degrees.y -= mouse_input.x * mouse_sensitivity
	head.rotation_degrees.x -= mouse_input.y * mouse_sensitivity
	head.rotation.x = clamp(head.rotation.x, deg_to_rad(-90), deg_to_rad(90))
	mouse_input = Vector2.ZERO
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	move_and_slide()
