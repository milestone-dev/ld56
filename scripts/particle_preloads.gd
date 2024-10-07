extends Node3D
@onready var spray_particles: GPUParticles3D = $SprayParticles

func _ready() -> void:
	spray_particles.emitting = true
