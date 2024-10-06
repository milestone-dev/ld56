extends StaticBody3D
class_name TardigradeContainer
@onready var incubator: Incubator = $incubator/incubator
#
func interact(player : Player):
	incubator.interact(player)
