extends StaticBody3D
class_name TardigradeContainer
@export var label : Label3D

var count := 0

func interact(player : Player):
	count += player.tardigrade_count
	player.tardigrade_count = 0
	update_count()

func update_count():
	label.text = "Tardigrades: %d" % count

func _ready() -> void:
	update_count()
