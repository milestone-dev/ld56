extends Node3D

@export var env : WorldEnvironment
@export var lightningNodes : Node3D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#0-3
	env.environment.ssao_enabled = Settings.gfx_quality > 2
	env.environment.ssr_enabled = Settings.gfx_quality > 2
	env.environment.fog_enabled = Settings.gfx_quality > 1
	env.environment.glow_enabled = Settings.gfx_quality > 2
	env.environment.ssil_enabled = Settings.gfx_quality > 2
	if Settings.gfx_quality > 0:
		env.environment.reflected_light_source = Environment.REFLECTION_SOURCE_SKY
	else:
		env.environment.reflected_light_source = Environment.REFLECTION_SOURCE_DISABLED

	lightningNodes.get_node("%Probes").visible = Settings.gfx_quality > 2
	lightningNodes.get_node("%Spotlights").visible = Settings.gfx_quality > 1
	lightningNodes.get_node("%CeilingLights").visible = Settings.gfx_quality > 1
	lightningNodes.get_node("%GlobalLight").visible = Settings.gfx_quality < 2
