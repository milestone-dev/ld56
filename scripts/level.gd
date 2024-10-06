extends Node3D

@export var env : WorldEnvironment
@export var lightningNodes : Node3D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
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
