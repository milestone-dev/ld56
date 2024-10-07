extends Node
var mouse_sensitivity : float = 0.1

var _gfx_quality: int = 3
@export_range(1, 4) var gfx_quality : int = 4:
	get: return _gfx_quality
	set(value):
		print("_gfx_quality", value)
		if value < 1 || value > 4:
			push_error("gfx_quality(1...4) out of range: ", value)
			value = min(max(0, value), 4)
		_gfx_quality = value
		var level = 	get_tree().get_first_node_in_group("level") as Level
		if level: level.update_gfx_settings()

var particle_amont_ratio: float:
	get: return [0, 0.1, 0.3, 0.65, 1][gfx_quality]

# Also putting balancing stuff in here for now
var kitten_drop_timer_max := 15.0
var kitten_spawn_min := 10000
var kitten_spawn_max := 70000
var kitten_base_increment_after_sleep := 25000
var difficulty := 6.0

@onready var defaultFullscreen: int = 3 # 3 = Borderless Fullscreen, 4 = Native Fullscreen

func _shortcut_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed:
			if event.is_action("toggle_fullscreen"):
				toggle_fullscreen()
			elif event.is_action("maximize_window"):
				maximize_window()

func _ready() -> void:
	if OS.has_feature("web"):
		gfx_quality = 3

func toggle_fullscreen() -> void:
	if DisplayServer.window_get_mode(0) != defaultFullscreen:
		DisplayServer.window_set_mode(defaultFullscreen)
	else:
		DisplayServer.window_set_mode(0)
		DisplayServer.window_set_flag(1, false, 0)


func maximize_window() -> void:
	if DisplayServer.window_get_mode(0) != 2:
		DisplayServer.window_set_mode(2)
		DisplayServer.window_set_flag(1, false, 0)
	else:
		DisplayServer.window_set_mode(0)
		DisplayServer.window_set_flag(1, false, 0)
