extends StaticBody3D

class_name Roomba

enum State {
	SLEEPING,
	IDLE,
	ROAMING,
	RETURNING_HOME,
	CHASING_PLAYER
}

#Start with State.SLEEPING
var state: State = State.IDLE

var player : Player
var home : Node3D
var movement_delta : float
var returning_home := false

const HOME_REST_TIMER_MAX := 3.0
var home_rest_timer := HOME_REST_TIMER_MAX

const ATTACK_COOLDOWN_MAX := 0.3
var attack_cooldown := ATTACK_COOLDOWN_MAX
@export var movement_speed: float = 2.0
@export var navigation_agent : NavigationAgent3D
@export var sprite : Sprite3D
@export var sleeping_texture : Texture2D
@export var idle_texture : Texture2D
@export var roaming_texture : Texture2D
@export var chasing_texture : Texture2D
@export var returning_texture : Texture2D


func _ready() -> void:
	player = get_tree().get_first_node_in_group("player") as Player
	home = get_tree().get_first_node_in_group("roomba_home") as Node3D
	navigation_agent.velocity_computed.connect(Callable(_on_velocity_computed))

func awake():
	state = State.ROAMING
func hit_reset():
	state = State.RETURNING_HOME

func update_target(delta:float):
	match state:
		State.SLEEPING:
			sprite.texture = sleeping_texture
		State.IDLE:
			sprite.texture = idle_texture
			if player.kitten_count > 0:
				state = State.CHASING_PLAYER
			else:
				navigation_agent.target_position = NavigationServer3D.map_get_random_point(get_world_3d().navigation_map, 1, false)
				state = State.ROAMING
		State.ROAMING:
			sprite.texture = roaming_texture
			if player.kitten_count > 0:
				state = State.CHASING_PLAYER
			elif navigation_agent.is_navigation_finished():
				navigation_agent.target_position = NavigationServer3D.map_get_random_point(get_world_3d().navigation_map, 1, false)
				state = State.ROAMING
		State.RETURNING_HOME:
			sprite.texture = returning_texture
			if global_position.distance_to(home.global_position) < 1:
				home_rest_timer -= delta
				if home_rest_timer < 0:
					home_rest_timer = HOME_REST_TIMER_MAX
					state = State.IDLE
			else:
				navigation_agent.target_position = home.global_position
		State.CHASING_PLAYER:
			sprite.texture = chasing_texture
			if player.kitten_count > 0:
				navigation_agent.target_position = player.global_position
				if global_position.distance_to(player.global_position) < 1:
					if attack_cooldown < 0:
						attack_cooldown = ATTACK_COOLDOWN_MAX
						player.drop_kittens()
			else:
				state = State.IDLE

func _physics_process(delta):
	attack_cooldown -= delta
	update_target(delta)
	# Do not query when the map has never synchronized and is empty.
	if NavigationServer3D.map_get_iteration_id(navigation_agent.get_navigation_map()) == 0:
		return
	if navigation_agent.is_navigation_finished():
		return

	movement_delta = movement_speed * delta
	var next_path_position: Vector3 = navigation_agent.get_next_path_position()
	var new_velocity: Vector3 = global_position.direction_to(next_path_position) * movement_delta
	if navigation_agent.avoidance_enabled:
		navigation_agent.set_velocity(new_velocity)
	else:
		_on_velocity_computed(new_velocity)

func _on_velocity_computed(safe_velocity: Vector3) -> void:
	global_position = global_position.move_toward(global_position + safe_velocity, movement_delta)
