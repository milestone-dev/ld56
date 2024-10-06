extends StaticBody3D
class_name Incubator

var turned_on : bool = false
@export var max_emissive = 8.0

@onready var incubator: MeshInstance3D = $incubator
@onready var light: SpotLight3D = $"SpotLight3D"
@onready var timer: Timer = Timer.new()

var material : Material

func _ready() -> void:
	material = incubator.get_surface_override_material(0)
	material.set_shader_parameter("EmissiveStrength", max_emissive * float(turned_on))

	timer.wait_time = 3.0
	timer.one_shot = true  # We want the timer to run only once per activation
	timer.connect("timeout", Callable(self, "_turn_off"))
	add_child(timer)

func interact(player : Player):
	turned_on = true

	material.set_shader_parameter("EmissiveStrength", max_emissive * float(turned_on))
	light.visible = turned_on
	timer.start()

func _turn_off() -> void:
	turned_on = false
	material.set_shader_parameter("EmissiveStrength", max_emissive * float(turned_on))
	light.visible = turned_on
