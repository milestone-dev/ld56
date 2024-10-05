extends StaticBody3D
class_name TardigradeContainer
@export var label : Label3D

var count := 0

func update(c : int):
	count += c
	label.text = "Tardigrades: %d" % count

func _ready() -> void:
	update(0)
