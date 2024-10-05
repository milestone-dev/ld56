extends StaticBody3D
class_name KittenContainer
@export var label : Label3D

var count := 0

func update(c : int):
	count += c
	label.text = "Kittens: %d / 1 000 000" % count

func _ready() -> void:
	update(0)
