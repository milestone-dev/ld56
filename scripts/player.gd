extends CharacterBody3D
class_name Player

enum Tool {
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

var current_tool := Tool.PICKER
var mouse_input : Vector2
var scanner_showing := false

var kitten_count := 0;
var tardigrade_count := 0;
var kitten_detection_level := 0
const KITTEN_DETECTION_LEVEL_MAX := 1000

const SCAN_ENERGY_MAX := 100.0
const SCAN_ENERGY_COST := 4.0
var scan_energy := SCAN_ENERGY_MAX

const SPRAY_ENERGY_MAX := 100.0
const SPRAY_ENERGY_COST := 4.0
var spray_energy := SPRAY_ENERGY_MAX

const KITTEN_DISAPPEAR_TIMER_MAX := 20.0
var kitten_disappear_timer := KITTEN_DISAPPEAR_TIMER_MAX

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

	# make kittens and tardigrades fall out of your hand
	# placeholder impl for now
	kitten_disappear_timer -= delta
	if kitten_disappear_timer <= 0:
		kitten_disappear_timer = KITTEN_DISAPPEAR_TIMER_MAX
		kitten_count = max(0, kitten_count - 1)
		tardigrade_count = max(0, tardigrade_count - 1)

	scanner_showing =  Input.is_action_pressed("tool_enable_scanner")

	# jump, interact
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	use_tool()

	update_scanner()
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

func update_scanner():
	kitten_detection_level = 0
	for kitten_cluster : Node3D in get_tree().get_nodes_in_group("kitten_cluster"):
		var distance = global_position.distance_to(kitten_cluster.global_position)
		if distance < 1: kitten_detection_level += 100
		elif distance < 2: kitten_detection_level += 75
		elif distance < 3: kitten_detection_level += 33
		elif distance < 5: kitten_detection_level += 15
		elif distance < 10: kitten_detection_level += 5

	var collider = interaction_ray.get_collider()
	if collider and collider is KittenCluster:
		kitten_detection_level = KITTEN_DETECTION_LEVEL_MAX

func use_tool():
	var either_pressed = Input.is_action_just_pressed("tool_left") or Input.is_action_just_pressed("tool_right")
	if Input.is_action_just_pressed("tool_left"): current_tool = Tool.PICKER
	elif Input.is_action_just_pressed("tool_right"): current_tool = Tool.SPRAYER
	if !either_pressed: return
	# First check for no targeted objects and return early
	if not interaction_ray.is_colliding():
		if current_tool == Tool.SPRAYER:
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
				kitten_cluster.spray(self)
		elif current_tool == Tool.PICKER:
			if collider is KittenCluster:
				kitten_cluster.retrieve(self)
