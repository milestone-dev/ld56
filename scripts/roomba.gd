extends RigidBody3D

var player : Player
var home : Node3D
@export var agent : NavigationAgent3D

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player") as Player
	home = get_tree().get_first_node_in_group("roomba_home") as Node3D

func _process(delta: float) -> void:
	if player.kitten_count > 0:
		agent.target_position = player.global_position
	else:
		agent.target_position = home.global_position


	agent.get_next_path_position()
