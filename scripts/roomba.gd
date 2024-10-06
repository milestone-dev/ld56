extends StaticBody3D

class_name Roomba

enum State {
	SLEEPING,
	IDLE,
	ROAMING,
	RETURNING_HOME,
	CHASING_PLAYER
}

var player : Player
var home : Node3D
var movement_delta : float
var state: State = State.SLEEPING

var home_rest_timer := 0.0
var attack_cooldown := 0.0

@export var awake_kittens_saved : int = 10
@export var movement_speed: float = 3.0
@export var home_rest_timer_max : float = 30.0
@export var kitten_destroy_timer: float = 0.3
@export var modulate_color : Color = Color.WHITE

@export var navigation_agent : NavigationAgent3D
@export var sprite : Sprite3D
@export var sleeping_texture : Texture2D
@export var idle_texture : Texture2D
@export var roaming_texture : Texture2D
@export var chasing_texture : Texture2D
@export var returning_texture : Texture2D
@export var audio_stream_player : AudioStreamPlayer3D

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player") as Player
	home = get_parent_node_3d() as Node3D
	sprite.modulate = modulate_color

func hit_reset():
	if state != State.SLEEPING:
		home_rest_timer = home_rest_timer_max
		state = State.RETURNING_HOME

func update_target(delta:float):
	match state:
		State.SLEEPING:
			sprite.texture = sleeping_texture
			audio_stream_player.stream_paused = true
			if player.kitten_saved_count >= awake_kittens_saved:
				state = State.IDLE
		State.IDLE:
			sprite.texture = idle_texture
			audio_stream_player.stream_paused = true
			if player.kitten_count > 0:
				state = State.CHASING_PLAYER
			else:
				navigation_agent.target_position = NavigationServer3D.map_get_random_point(get_world_3d().navigation_map, 1, false)
				state = State.ROAMING
		State.ROAMING:
			sprite.texture = roaming_texture
			audio_stream_player.stream_paused = false
			if player.kitten_count > 0:
				state = State.CHASING_PLAYER
			elif navigation_agent.is_navigation_finished():
				navigation_agent.target_position = NavigationServer3D.map_get_random_point(get_world_3d().navigation_map, 1, false)
				state = State.ROAMING
		State.RETURNING_HOME:
			sprite.texture = returning_texture
			audio_stream_player.stream_paused = false
			if global_position.distance_to(home.global_position) < 1:
				home_rest_timer -= delta
				sprite.texture = sleeping_texture
				audio_stream_player.stream_paused = true
				if home_rest_timer < 0:
					home_rest_timer = home_rest_timer_max
					state = State.IDLE
			else:
				navigation_agent.target_position = home.global_position
		State.CHASING_PLAYER:
			sprite.texture = chasing_texture
			audio_stream_player.stream_paused = false
			if player.kitten_count > 0:
				navigation_agent.target_position = player.global_position
				if global_position.distance_to(player.global_position) < 1:
					if attack_cooldown < 0:
						attack_cooldown = kitten_destroy_timer
						player.drop_kittens(1)
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
	global_position = global_position.move_toward(global_position + new_velocity, movement_delta)
