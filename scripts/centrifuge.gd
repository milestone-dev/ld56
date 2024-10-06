extends StaticBody3D
class_name Centrifuge

const SPEED := 20.0
const KNOB_INCREMENT := 90.0

enum SpinnerSetting {
	OFF,
	SPEED_ONE,
	SPEED_TWO
}

var speed_setting := SpinnerSetting.OFF
var current_speed : float = 0.0

var default_knob_rotation : Vector3
var knob_current_rotation : Vector3
@export var max_emissive = 8.0

@onready var spinner := $centrifuge_spinner
@onready var knob: StaticBody3D = $centrifuge_knob
@onready var lid: StaticBody3D = $centrifuge_spinner/centrifuge_lid

@onready var centrifuge_base: MeshInstance3D = $centrifuge_base

var material : Material

func _ready() -> void:
	material = centrifuge_base.get_surface_override_material(0)

	default_knob_rotation = knob.rotation_degrees


func interact(player : Player):
	if speed_setting == SpinnerSetting.OFF:
		speed_setting = SpinnerSetting.SPEED_ONE
	elif speed_setting == SpinnerSetting.SPEED_ONE:
		speed_setting = SpinnerSetting.SPEED_TWO
	else:
		speed_setting = SpinnerSetting.OFF


func _process(delta: float) -> void:

	current_speed = lerp(current_speed,(speed_setting*SPEED),0.01)

	spinner.rotate_y(current_speed*delta)

	knob_current_rotation = lerp(knob_current_rotation, Vector3(0,0,(speed_setting * -KNOB_INCREMENT)), 0.2)

	knob.rotation_degrees = default_knob_rotation + knob_current_rotation # Put the knob in the correct speed setting
	material.set_shader_parameter("EmissiveStrength", max_emissive * speed_setting)
