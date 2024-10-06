extends StaticBody3D
class_name KittenCluster

@export var sprite : Sprite3D
@export var label : Label3D
@export var particles: GPUParticles3D
var current_reveal_tween : Tween
var fade_out_timer := 5.0

@export var kitten_count := 0

@export var kitten_textures: Array[Texture2D] = []

var has_found_wall = false

const KITTEN_RESPAWN_TIMER_MAX := 5.0
var kitten_respawn_timer := 0.0

const FADED_OUT_COLOR = Color(1,1,1,0.0)

func has_kittens() -> bool:	return kitten_count > 0

var is_visible: bool:
	get: return sprite.modulate.a > 0

func _ready() -> void:
	sprite.modulate = FADED_OUT_COLOR;
	particles.emitting = false
	particles.emitting = 0
	particles.visible = false

func _process(delta: float) -> void:
	kitten_respawn_timer -= delta
	particles.amount = 1 if kitten_count < 1 else kitten_count
	if is_visible && particles.visible != is_visible:
		particles.restart()
	particles.emitting = is_visible
	particles.visible = is_visible

func _physics_process(delta: float) -> void:
	if is_visible && !has_found_wall:
		find_a_wall()

## call me from _physics_process
func find_a_wall():
	const directions = [
		Vector3.BACK, Vector3.FORWARD,
		Vector3.LEFT, Vector3.RIGHT,
		Vector3.UP, Vector3.DOWN,
		]
	var state = get_world_3d().direct_space_state
	var target = global_position + transform * Vector3.FORWARD * 0.1
	var query = PhysicsRayQueryParameters3D.create(global_position, target, 1)

	for dir in directions:
		query.to = global_position + dir * 1;
		var ray = state.intersect_ray(query)
		if ray.size() > 0:
			var point = global_transform.origin + ray.normal
			look_at(point, Vector3.UP if dir.y == 0 else Vector3.LEFT)
			var collider = $Particles/collider
			collider.position = to_local(ray.position)
			var mat = $Particles.process_material as ParticleProcessMaterial
			mat.gravity = global_transform.basis * Vector3.BACK
			break

	self.has_found_wall = true

func retrieve(player:Player):
	if sprite.modulate.a > FADED_OUT_COLOR.a:
		player.kitten_count += kitten_count
		if (randf()) < 0.2: player.tardigrade_count += 1
		kitten_count = 0
		label.text = "%d" % kitten_count
		if current_reveal_tween: current_reveal_tween.stop()
		sprite.modulate = FADED_OUT_COLOR;
		kitten_respawn_timer = KITTEN_RESPAWN_TIMER_MAX;

func add_kittens(count:int) -> bool:
	if kitten_respawn_timer > 0: return false
	kitten_count += count
	label.text = "%d" % kitten_count
	return true

func spray(player:Player):
	if !has_kittens(): return
	if current_reveal_tween:
		current_reveal_tween.stop()
		current_reveal_tween = null
	sprite.modulate = Color.WHITE
	current_reveal_tween = get_tree().create_tween()
	current_reveal_tween.tween_property(sprite, "modulate", FADED_OUT_COLOR, fade_out_timer)
