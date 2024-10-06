extends StaticBody3D
class_name TardigradeContainer
@export var label : Label3D
@onready var incubator: Incubator = $incubator/incubator

var count := 0

func interact(player : Player):
	count += player.tardigrade_count
	player.tardigrade_count = 0
	update_count()
	incubator.interact(player)

func update_count():
	label.text = "Tardigrades: %d" % count

func _ready() -> void:
	update_count()
