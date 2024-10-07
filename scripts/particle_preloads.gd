extends Node3D
@onready var spray_particles: GPUParticles3D = $SprayParticles
@onready var kitten_in_hand: GPUParticles3D = $KittenInHand

func _ready() -> void:
	spray_particles.emitting = true
	kitten_in_hand.emitting = true
