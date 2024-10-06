extends StaticBody3D
class_name KittenContainer

@export var label : Label3D

var count := 0

func interact(player : Player):
	player.kitten_saved_count += player.kitten_count
	player.kitten_count = 0
	update_count(player.kitten_saved_count)

func update_count(count:int):
	label.text = "Kittens: %d / 1 000 000" % count

func _ready() -> void:
	update_count(0)
