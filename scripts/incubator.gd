extends StaticBody3D
class_name Incubator

var turned_on : bool = false
var help : bool = false
@export var max_emissive = 8.0

@onready var incubator: MeshInstance3D = $incubator
@onready var light: SpotLight3D = $"SpotLight3D"

var material : Material

func _ready() -> void:
	material = incubator.get_surface_override_material(0)
	material.set_shader_parameter("EmissiveStrength", max_emissive * float(turned_on))
	print("There is an incubator in the scene")

func interact(player : Player):
	print("Incubator is interacted upon")
	turned_on = !turned_on
	if turned_on:
		material.set_shader_parameter("EmissiveStrength", max_emissive * float(turned_on))
	light.visible = turned_on


func _process(delta: float) -> void:
	help = true
