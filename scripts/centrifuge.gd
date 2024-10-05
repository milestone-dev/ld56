extends StaticBody3D
class_name Centrifuge

const SPEED := 20.0
const KNOB_INCREMENT := 90.0

enum SpinnerSetting {
	OFF,
	SPEED_ONE,
	SPEED_TWO
}

var speedSetting := SpinnerSetting.SPEED_TWO #CHANGE THIS TO 'OFF' WHEN INTERACT WORKS
var current_speed : float = 0.0

var default_knob_position : Vector3
var max_emissive = 4.0

@onready var spinner := $centrifuge_spinner
@onready var knob: StaticBody3D = $centrifuge_knob
@onready var lid: StaticBody3D = $centrifuge_spinner/centrifuge_lid

@onready var centrifuge_base: MeshInstance3D = $centrifuge_base

var material : Material

func _ready() -> void:
	material = centrifuge_base.get_surface_override_material(0)
	
	default_knob_position = knob.rotation_degrees
	
	print("There is a centrifuge in the scene")
	
	
func interact(player : Player):
	print("Centrifuge is interacted upon")
	if speedSetting == SpinnerSetting.OFF:
		speedSetting = SpinnerSetting.SPEED_ONE
	elif speedSetting == SpinnerSetting.SPEED_ONE:
		speedSetting = SpinnerSetting.SPEED_TWO
	else:
		speedSetting = SpinnerSetting.OFF
	
	
func _process(delta: float) -> void:
	current_speed = lerp(current_speed,(speedSetting*SPEED),0.01)
	if speedSetting != SpinnerSetting.OFF:
		spinner.rotate_y(current_speed*delta)
	
	knob.rotation_degrees = default_knob_position + Vector3(0,0,(speedSetting * KNOB_INCREMENT)) # Put the knob in the correct speed setting
	material.set_shader_parameter("EmissiveStrength", max_emissive * speedSetting)
