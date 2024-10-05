extends StaticBody3D
class_name KittenContainer
@export var label : Label3D

var count := 0

func interact(player : Player):
	count += player.kitten_count
	player.kitten_count = 0
	update_count()

func update_count():
	label.text = "Kittens: %d / 1 000 000" % count

func _ready() -> void:
	update_count()
