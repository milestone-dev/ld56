extends StaticBody3D
class_name SprayRecharger

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func interact(player : Player):
	player.spray_energy = player.SPRAY_ENERGY_MAX
	animation_player.play("test")
