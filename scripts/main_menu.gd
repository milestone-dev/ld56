extends Control

@export var level_scene : PackedScene
@export var test_level_scene : PackedScene
@export var start_game_button : Button

@export var sens_slider : HSlider
@export var gfx_slider : HSlider
@export var sfx_slider : HSlider
@export var music_slider : HSlider

func start_game(): get_tree().change_scene_to_packed(level_scene)
func start_test_level(): get_tree().change_scene_to_packed(test_level_scene)

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	start_game_button.grab_focus()
	sens_slider.value = Settings.mouse_sensitivity
	gfx_slider.value = Settings.gfx_quality
	sfx_slider.value = AudioServer.get_bus_volume_db(1)
	music_slider.value = AudioServer.get_bus_volume_db(2)

func sfx_volume_slider_value_changed(value:float):
	AudioServer.set_bus_volume_db(1, value)
func music_volume_slider_value_changed(value:float):
	AudioServer.set_bus_volume_db(2, value)
func mouse_sens_slider_value_changed(value:float):
	Settings.mouse_sensitivity = value
func gfx_slider_value_changed(value:float):
	Settings.gfx_quality = (value as int)
