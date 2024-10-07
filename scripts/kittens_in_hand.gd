extends Node3D
class_name KittensInHand

@export var particles: GPUParticles3D
@export_range(0, 10000) var kitten_count: int = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _process(_delta: float) -> void:
	particles.amount_ratio = Settings.particle_amont_ratio
	particles.amount = max(1, kitten_count)
	particles.emitting = kitten_count > 0
