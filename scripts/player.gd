extends CharacterBody3D
class_name Player

enum Tool {
	SPRAYER,
	PICKER,
	COUNT
}

var kitten_pool := 1000000

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
var mouse_sensitivity : float = 0.1
@export var spray_particles : GPUParticles3D
@export var ui : UI

@export_category("SFX")
@export var sfx_audio_player : AudioStreamPlayer
@export var sfx_step_audio_player : AudioStreamPlayer
@export var sfx_scan_audio_player : AudioStreamPlayer
@export var sfx_spray : AudioStream
@export var sfx_pick : AudioStream
@export var sfx_switch : AudioStream
@export var sfx_jump : AudioStream
@export var sfx_land : AudioStream
@export var sfx_use : AudioStream
@export var sfx_refill : AudioStream
@export var sfx_scan_beep : AudioStream
@export var sfx_steps : Array[AudioStream]

@export_category("Music")
@export var music_audio_player : AudioStreamPlayer
@export var music_track : AudioStream

var current_tool := Tool.PICKER
var mouse_input : Vector2
var scanner_showing := false
var is_sprinting := false
var is_crouching := false
var is_jumping := false

var debug_mode := false

const STEP_SFX_TIMER_MAX := 0.3
const STEP_SRPING_SFX_TIMER_MAX := 0.15
var step_sfx_timer := 0.0

const SCAN_SFX_TIMER_MAX := 0.4
var scan_sfx_timer := 0.0
const SCAN_MAX_PITCH := 2.0

var kitten_saved_count := 0
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
const SPRAY_ENERGY_COST := SPRAY_ENERGY_MAX/100.0
var spray_energy := SPRAY_ENERGY_MAX

const KITTEN_DISAPPEAR_TIMER_MAX := 1.0
var kitten_disappear_timer := KITTEN_DISAPPEAR_TIMER_MAX

func _ready() -> void:
	mouse_sensitivity = Settings.mouse_sensitivity
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	mesh_instance.hide()
	start_level()

func _input(event: InputEvent) -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event is not InputEventMouseMotion or Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return
	mouse_input.x += event.relative.x
	mouse_input.y += event.relative.y

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("toggle_menu"):
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
		return

	if kitten_saved_count >= 1000000:
		get_tree().change_scene_to_file("res://scenes/win_screen.tscn")
		return

	# level management
	manage_level(delta)

	#debug mode
	if Input.is_action_just_pressed("toggle_debug"): debug_mode = !debug_mode
	if Input.is_action_just_pressed("debug_add_kittens"):
		for kitten_cluster : KittenCluster in get_tree().get_nodes_in_group("kitten_cluster"):
			kitten_cluster.spray(self)
			kitten_cluster.retrieve(self)
			kitten_cluster.kitten_respawn_timer = 0.5
			play_sfx(sfx_pick)

	# make kittens and tardigrades fall out of your hand
	# placeholder impl for now
	kitten_disappear_timer -= delta
	if kitten_disappear_timer <= 0:
		drop_kittens()
		kitten_disappear_timer = KITTEN_DISAPPEAR_TIMER_MAX

	# fall, land, jump, crouch
	if not is_on_floor(): velocity += get_gravity() * delta
	if is_jumping and is_on_floor():
		is_jumping = false
		play_sfx(sfx_land)
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		is_jumping = true
		play_sfx(sfx_jump)
	is_crouching = Input.is_action_pressed("crouch")
	if is_crouching: collision_shape.scale = Vector3(1, CROUCH_SIZE, 1)
	else: collision_shape.scale = Vector3.ONE

	# interaction, tools, scanners
	manage_interactions()
	scanner_showing = Input.is_action_pressed("tool_enable_scanner") and scan_energy > 0.0
	if scanner_showing:
		scan_energy = max(0.0, scan_energy - delta)
		update_scanner()
	sfx_scan_audio_player.stream_paused = !scanner_showing
	var val := linear_to_db((kitten_detection_level as float / KITTEN_DETECTION_LEVEL_MAX as float))
	sfx_scan_audio_player.volume_db = clampf(val, -80, 0)

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

	# walking
	step_sfx_timer -= delta
	var speed = WALK_SPEED
	if is_sprinting and is_on_floor(): speed = SPRINT_SPEED
	elif is_crouching: speed = CROUCH_SPEED
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		if step_sfx_timer <= 0.0 and is_on_floor():
			#print("step")
			if is_sprinting: step_sfx_timer = STEP_SRPING_SFX_TIMER_MAX
			else: step_sfx_timer = STEP_SFX_TIMER_MAX
			sfx_step_audio_player.stream = sfx_steps.pick_random()
			sfx_step_audio_player.pitch_scale = randf_range(0.5, 1.5)
			sfx_step_audio_player.play()
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	move_and_slide()
	ui.update(self)

func drop_kittens(count : int = 1):
	var kittens_lost : int = min(kitten_count, count)
	var tardigrades_lost := count
	Progress.kittens_leaked += kittens_lost
	kitten_pool += kittens_lost
	kitten_count = max(0, kitten_count - kittens_lost)
	tardigrade_count = max(0, tardigrade_count - tardigrades_lost)

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
func spray():
	var s = spray_particles.duplicate() as GPUParticles3D
	get_tree().root.add_child(s)
	s.global_transform = spray_particles.global_transform
	s.one_shot=true
	s.emitting=true
	s.connect("finished", s.queue_free)
	ui.spray_sprite.stop()
	ui.spray_sprite.play()
	spray_energy = max(0, spray_energy - SPRAY_ENERGY_COST)
	play_sfx(sfx_spray)

func manage_interactions():
	var either_pressed = Input.is_action_just_pressed("tool_left") or Input.is_action_just_pressed("tool_right")
	if Input.is_action_just_pressed("tool_left"): current_tool = Tool.PICKER
	elif Input.is_action_just_pressed("tool_right"): current_tool = Tool.SPRAYER
	if !either_pressed: return

	# Always consume spray energy regardless of where you spray
	if current_tool == Tool.SPRAYER and spray_energy > 0:
		spray()

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
					if kitten_cluster.is_sprayed():
						kitten_cluster.retrieve(self)
						ui.pick_sprite.stop()
						ui.pick_sprite.play()
						play_sfx(sfx_pick)

	var collider = interaction_ray.get_collider()
	if collider is Roomba:
		var roomba := collider as Roomba
		roomba.hit_reset()
	elif collider is KittenContainer:
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
	elif collider is Incubator:
		var incubator := collider as Incubator
		incubator.interact(self)
		return
	elif current_tool == Tool.PICKER:
		# Pick randomly in the air without effect
		ui.pick_sprite.stop()
		ui.pick_sprite.play()

func start_level():
	print("Level start")
	for kitten_cluster : KittenCluster in get_tree().get_nodes_in_group("kitten_cluster"):
		distribute_random_kittens(kitten_cluster)

func distribute_random_kittens(kitten_cluster: KittenCluster):
	var kitten_distriution_count = min(kitten_pool, randi_range(Settings.kitten_spawn_min, Settings.kitten_spawn_max))
	if kitten_cluster.add_kittens(kitten_distriution_count):
		kitten_pool -= kitten_distriution_count

func manage_level(delta:float):
	Progress.time_played += delta
	if kitten_pool <= 0: return
	for kitten_cluster : KittenCluster in get_tree().get_nodes_in_group("kitten_cluster"):
		kitten_cluster.label.visible = debug_mode
		if kitten_cluster.kitten_count == 0 and kitten_cluster.kitten_respawn_timer <= 0:
			prints("Refill", kitten_cluster.name)
			distribute_random_kittens(kitten_cluster)

func play_sfx(sfx:AudioStream):
	sfx_audio_player.stream = sfx
	sfx_audio_player.play()
