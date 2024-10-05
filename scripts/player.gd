extends CharacterBody3D
class_name Player

enum Tool {
	SPRAYER,
	PICKER,
	COUNT
}

var kitten_pool := 1000000
var play_time := 0.0

const WALK_SPEED := 5.0
const SPRINT_SPEED := 9.0
const CROUCH_SPEED := 2.0
const JUMP_VELOCITY = 4.5
const CROUCH_SIZE = 0.3

@export var head : Node3D
@export var interaction_ray : RayCast3D
@export var collision_shape : CollisionShape3D
@export var scanner_point : Marker3D
@export var interaction_shape : Area3D
@export var mesh_instance : MeshInstance3D
@export var mouse_sensitivity : float = 0.1
@export var ui : UI

var current_tool := Tool.PICKER
var mouse_input : Vector2
var scanner_showing := false
var is_sprinting := false
var is_crouching := false

var debug_mode := false

var kitten_count := 0;
var tardigrade_count := 0;
var kitten_detection_level := 0
const KITTEN_DETECTION_LEVEL_MAX := 1000

const SPRINT_ENERGY_MAX := 5.0
var sprint_energy := SPRINT_ENERGY_MAX

const SCAN_ENERGY_MAX := 180.0
const SCAN_ENERGY_COST := 4.0
var scan_energy := SCAN_ENERGY_MAX
const SCAN_RANGE_CUTOFF := 5.0

const SPRAY_ENERGY_MAX := 100.0
const SPRAY_ENERGY_COST := SPRAY_ENERGY_MAX/6.0
var spray_energy := SPRAY_ENERGY_MAX

const KITTEN_DISAPPEAR_TIMER_MAX := 5.0
var kitten_disappear_timer := KITTEN_DISAPPEAR_TIMER_MAX

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	mesh_instance.hide()
	start_level()

func _input(event: InputEvent) -> void:
	if event is not InputEventMouseMotion or Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return
	mouse_input.x += event.relative.x
	mouse_input.y += event.relative.y

func _physics_process(delta: float) -> void:
	# level management
	manage_level(delta)

	#debug mode
	if Input.is_action_just_pressed("toggle_debug"): debug_mode = !debug_mode

	# make kittens and tardigrades fall out of your hand
	# placeholder impl for now
	kitten_disappear_timer -= delta
	if kitten_disappear_timer <= 0:
		kitten_disappear_timer = KITTEN_DISAPPEAR_TIMER_MAX
		var kittens_lost := 1
		var tardigrades_lost := 1
		kitten_pool += kittens_lost
		kitten_count = max(0, kitten_count - kittens_lost)
		tardigrade_count = max(0, tardigrade_count - tardigrades_lost)

	# fall, jump, crouch
	if not is_on_floor(): velocity += get_gravity() * delta
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	is_crouching = Input.is_action_pressed("crouch")
	if is_crouching: collision_shape.scale = Vector3(1, CROUCH_SIZE, 1)
	else: collision_shape.scale = Vector3.ONE

	# interaction, tools, scanners
	manage_interactions()
	scanner_showing = Input.is_action_pressed("tool_enable_scanner") and scan_energy > 0.0
	if scanner_showing:
		scan_energy = max(0.0, scan_energy - delta)
		update_scanner()

	# looking, walking
	rotation_degrees.y -= mouse_input.x * mouse_sensitivity
	head.rotation_degrees.x -= mouse_input.y * mouse_sensitivity
	head.rotation.x = clamp(head.rotation.x, deg_to_rad(-90), deg_to_rad(90))
	mouse_input = Vector2.ZERO
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	# spriting
	is_sprinting = Input.is_action_pressed("sprint") and sprint_energy > 0.0 and !is_crouching
	if is_sprinting: sprint_energy -= delta
	else: sprint_energy = min(sprint_energy + delta, SPRINT_ENERGY_MAX)

	var speed = WALK_SPEED
	if is_sprinting and is_on_floor(): speed = SPRINT_SPEED
	elif is_crouching: speed = CROUCH_SPEED
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	move_and_slide()
	ui.update(self)

func update_scanner():
	kitten_detection_level = 0
	for kitten_cluster : Node3D in get_tree().get_nodes_in_group("kitten_cluster"):
		if kitten_cluster.has_kittens():
			var marker_distance = scanner_point.global_position.distance_to(kitten_cluster.global_position)
			var player_distance = global_position.distance_to(kitten_cluster.global_position)
			var distance = min(marker_distance, player_distance)
			if distance > SCAN_RANGE_CUTOFF: continue
			kitten_detection_level += (SCAN_RANGE_CUTOFF - distance) * 150

	for collider : Node3D in interaction_shape.get_overlapping_bodies():
		if collider and collider is KittenCluster and (collider as KittenCluster).has_kittens():
			kitten_detection_level = KITTEN_DETECTION_LEVEL_MAX

func manage_interactions():
	var either_pressed = Input.is_action_just_pressed("tool_left") or Input.is_action_just_pressed("tool_right")
	if Input.is_action_just_pressed("tool_left"): current_tool = Tool.PICKER
	elif Input.is_action_just_pressed("tool_right"): current_tool = Tool.SPRAYER
	if !either_pressed: return
	# First check for no targeted objects and return early
	if not interaction_ray.is_colliding():
		if current_tool == Tool.SPRAYER:
			spray_energy = max(0, spray_energy - SPRAY_ENERGY_COST)

	# Check targeted objects
	var colliders = interaction_shape.get_overlapping_bodies()
	for c in colliders:
		if c is KittenCluster:
			var kitten_cluster := c as KittenCluster
			if current_tool == Tool.SPRAYER:
				if spray_energy > 0:
					kitten_cluster.spray(self)
			elif current_tool == Tool.PICKER:
				if c is KittenCluster:
					kitten_cluster.retrieve(self)

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
	elif collider is Centrifuge:
		var centrifuger := collider as Centrifuge
		centrifuger.interact(self)
		return

func start_level():
	print("Level start")
	for kitten_cluster : KittenCluster in get_tree().get_nodes_in_group("kitten_cluster"):
		distribute_random_kittens(kitten_cluster)

func distribute_random_kittens(kitten_cluster: KittenCluster):
	var kitten_min = 1
	var kitten_max = 100
	var kitten_distriution_count = min(kitten_pool, randi_range(kitten_min, kitten_max))
	if kitten_cluster.add_kittens(kitten_distriution_count):
		kitten_pool -= kitten_distriution_count

func manage_level(delta:float):
	play_time += delta
	for kitten_cluster : KittenCluster in get_tree().get_nodes_in_group("kitten_cluster"):
		kitten_cluster.label.visible = debug_mode
		if kitten_cluster.kitten_count == 0 and kitten_cluster.kitten_respawn_timer <= 0:
			prints("Refill", kitten_cluster.name)
			distribute_random_kittens(kitten_cluster)
