extends StaticBody3D
class_name ScannerRecharger

func interact(player : Player):
	player.scan_energy = player.SCAN_ENERGY_MAX
