extends Node3D

class_name Level

@export var env : WorldEnvironment
@export var lightningNodes : Node3D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_gfx_settings()
	NavigationServer3D.map_set_cell_size(get_world_3d().navigation_map,0.03)
	
	

func update_gfx_settings():
	#GFX Quality is 1-4
	env.environment.ssao_enabled = Settings.gfx_quality > 3
	env.environment.ssr_enabled = Settings.gfx_quality > 3
	env.environment.fog_enabled = Settings.gfx_quality > 2
	env.environment.glow_enabled = Settings.gfx_quality > 3
	env.environment.ssil_enabled = Settings.gfx_quality > 3
	if Settings.gfx_quality > 2:
		env.environment.reflected_light_source = Environment.REFLECTION_SOURCE_SKY
	else:
		env.environment.reflected_light_source = Environment.REFLECTION_SOURCE_DISABLED

	lightningNodes.get_node("%Probes").visible = Settings.gfx_quality > 3
	lightningNodes.get_node("%Spotlights").visible = Settings.gfx_quality > 2
	lightningNodes.get_node("%CeilingLights").visible = Settings.gfx_quality > 2

	# Turn on global light if no ceiling lights
	lightningNodes.get_node("%GlobalLight").visible = !lightningNodes.get_node("%CeilingLights").visible
