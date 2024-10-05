extends StaticBody3D
class_name Incubator

var turned_on : bool = false

@export var max_emissive = 4.0

@onready var incubator: MeshInstance3D = $incubator
@onready var light: SpotLight3D = $"SpotLight3D"

var material : Material

func _ready() -> void:
	material = incubator.get_surface_override_material(0)
	
	print("There is an incubator in the scene")
	
	
func interact(player : Player):
	print("Incubator is interacted upon")
	turned_on = !turned_on
	if turned_on:
		material.set_shader_parameter("EmissiveStrength", max_emissive * turned_on)
	light.visible = turned_on
