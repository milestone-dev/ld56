extends StaticBody3D
class_name SprayRecharger

func interact(player : Player):
	player.spray_energy = player.SPRAY_ENERGY_MAX
