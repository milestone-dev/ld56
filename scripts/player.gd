extends CharacterBody3D
class_name Player

enum Tool {
	SCANNER,
	SPRAYER,
	PICKER,
	COUNT
}

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@export var head : Node3D
@export var interaction_ray : RayCast3D
@export var mouse_sensitivity : float = 0.1
@export var ui : UI

var current_tool := Tool.SCANNER
var mouse_input : Vector2

var kitten_count = 0;
var tardigrade_count = 0;

const SCAN_ENERGY_MAX := 100.0
const SCAN_ENERGY_COST := 4.0
var scan_energy := SCAN_ENERGY_MAX

const SPRAY_ENERGY_MAX := 100.0
const SPRAY_ENERGY_COST := 4.0
var spray_energy := SPRAY_ENERGY_MAX

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
		if (current_tool as int) < 0: current_tool = ((Tool.COUNT - 1 )as int) as Tool

	# jump, interact
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	if Input.is_action_just_pressed("use_tool"):
		use_tool()

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


func use_tool():
	# First check for no targeted objects and return early
	if not interaction_ray.is_colliding():
		if current_tool == Tool.SCANNER:
			scan_energy = max(0, scan_energy - SCAN_ENERGY_COST)
		elif current_tool == Tool.SPRAYER:
			spray_energy = max(0, spray_energy - SPRAY_ENERGY_COST)
		return

	# Check targeted objects
	var collider = interaction_ray.get_collider()
	if collider is KittenContainer:
		var kitten_container := collider as KittenContainer
		kitten_container.interact(self)
		return
	elif collider is TardigradeContainer:
		var tardigrade_container := collider as TardigradeContainer
		tardigrade_container.interact(self)
		return
	elif collider is ScannerRecharger:
		var scanner_recharger := collider as ScannerRecharger
		scanner_recharger.interact(self)
		return
	elif collider is SprayRecharger:
		var spray_recharger := collider as SprayRecharger
		spray_recharger.interact(self)
		return
	elif collider is KittenCluster:
		var kitten_cluster := collider as KittenCluster
		if current_tool == Tool.SPRAYER:
			if spray_energy > 0:
				kitten_cluster.reveal(self)
		elif current_tool == Tool.PICKER:
			if collider is KittenCluster:
					kitten_cluster.interact(self)
