extends StaticBody3D
class_name SprayRecharger

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var glow_cone: Node3D = $glow_cone

var player1 : Player

func interact(player : Player):
	player.spray_energy = player.SPRAY_ENERGY_MAX
	animation_player.play("test")
	player1.spray_empty = false
	glow_cone.visible = false


func _ready() -> void:
	player1 = get_tree().get_first_node_in_group("player") as Player
	glow_cone.visible = false

func _process(delta: float) -> void:
	if player1.spray_empty == true:
		glow_cone.visible = true
	pass
