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
@export var state_sprite : Sprite3D
@export var ring_sprite : Sprite3D
@export var sleeping_texture : Texture2D
@export var idle_texture : Texture2D
@export var roaming_texture : Texture2D
@export var chasing_texture : Texture2D
@export var returning_texture : Texture2D
@export_category("SFX")
@export var motor_audio_stream_player : AudioStreamPlayer3D
@export var sfx_audio_stream_player : AudioStreamPlayer3D
@export var start_chasing_audio_stream : AudioStream
@export var become_idle_audio_stream : AudioStream
@export var fall_asleep_audio_stream : AudioStream


@onready var model: MeshInstance3D = $CollisionShape3D/doomba2/doomba/doomba
var material : Material
@onready var decal: Decal = $CollisionShape3D/doomba2/Decal


func _ready() -> void:
	player = get_tree().get_first_node_in_group("player") as Player
	home = get_parent_node_3d() as Node3D
	modulate_color.a = 0.5
	ring_sprite.modulate = modulate_color
	
	material = model.get_surface_override_material(1)
	

func hit_reset():
	if state != State.SLEEPING:
		play_sfx(fall_asleep_audio_stream)
		home_rest_timer = home_rest_timer_max
		state = State.RETURNING_HOME
		Progress.roombas_sent_home += 1

func update_target(delta:float):
	match state:
		State.SLEEPING:
			state_sprite.texture = sleeping_texture
			motor_audio_stream_player.stream_paused = true
			if player.kitten_saved_count >= awake_kittens_saved:
				state = State.IDLE
			material.set_shader_parameter("EmissiveColor", Color(1.0,1.0,1.0))
			decal.modulate = Color(0.0,0.0,0.0)
		State.IDLE:
			state_sprite.texture = idle_texture
			motor_audio_stream_player.stream_paused = true
			if player.kitten_count > 0:
				state = State.CHASING_PLAYER
				play_sfx(start_chasing_audio_stream)
			else:
				navigation_agent.target_position = NavigationServer3D.map_get_random_point(get_world_3d().navigation_map, 1, false)
				state = State.ROAMING
			material.set_shader_parameter("EmissiveColor", Color(1.0,1.0,0.0))
			decal.modulate = Color(1.0,1.0,0.0)
		State.ROAMING:
			state_sprite.texture = roaming_texture
			motor_audio_stream_player.stream_paused = false
			if player.kitten_count > 0:
				state = State.CHASING_PLAYER
				play_sfx(start_chasing_audio_stream)
			elif navigation_agent.is_navigation_finished():
				navigation_agent.target_position = NavigationServer3D.map_get_random_point(get_world_3d().navigation_map, 1, false)
				state = State.ROAMING
			material.set_shader_parameter("EmissiveColor", Color(0.5,1.0,0.5))
			decal.modulate = Color(0.5,1.0,0.5)
		State.RETURNING_HOME:
			state_sprite.texture = returning_texture
			motor_audio_stream_player.stream_paused = false
			if global_position.distance_to(home.global_position) < 1:
				home_rest_timer -= delta
				state_sprite.texture = sleeping_texture
				motor_audio_stream_player.stream_paused = true
				if home_rest_timer < 0:
					home_rest_timer = home_rest_timer_max
					state = State.IDLE
					play_sfx(become_idle_audio_stream)
			else:
				navigation_agent.target_position = home.global_position
			material.set_shader_parameter("EmissiveColor", Color(0.0,1.0,0.0))
			decal.modulate = Color(0.0,1.0,0.0)
		State.CHASING_PLAYER:
			state_sprite.texture = chasing_texture
			motor_audio_stream_player.stream_paused = false
			if player.kitten_count > 0:
				navigation_agent.target_position = player.global_position
				if global_position.distance_to(player.global_position) < 1:
					if attack_cooldown < 0:
						attack_cooldown = kitten_destroy_timer
						player.drop_kittens(1)
			else:
				state = State.IDLE
			material.set_shader_parameter("EmissiveColor", Color(1.0,0.0,0.0))
			decal.modulate = Color(1.0,0.0,0.0)


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


func play_sfx(sfx:AudioStream):
	sfx_audio_stream_player.stream = sfx
	sfx_audio_stream_player.play()
