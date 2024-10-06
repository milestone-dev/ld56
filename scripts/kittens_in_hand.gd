extends Node3D
class_name KittensInHand

@export var particles: GPUParticles3D
@export_range(0, 10000) var kitten_count: int = 0: 
	get:
		return particles.amount
	set(value):
		if value < 1:
			particles.emitting = false
		else:
			particles.amount = kitten_count
			particles.emitting = true
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
