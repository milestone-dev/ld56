extends Control

@export var level_scene : PackedScene
@export var test_level_scene : PackedScene
@export var start_game_button : Button

@export var sens_slider : HSlider
@export var gfx_slider : HSlider
@export var sfx_slider : HSlider
@export var music_slider : HSlider

const SFX_PREVIEW_TIMER_MAX := 0.15
var sfx_preview_timer := SFX_PREVIEW_TIMER_MAX
@export var sfx_audio_stream_player : AudioStreamPlayer

func start_game(): get_tree().change_scene_to_packed(level_scene)
func start_test_level(): get_tree().change_scene_to_packed(test_level_scene)

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	start_game_button.grab_focus()
	sens_slider.value = Settings.mouse_sensitivity
	gfx_slider.value = Settings.gfx_quality
	sfx_slider.value = AudioServer.get_bus_volume_db(1)
	music_slider.value = AudioServer.get_bus_volume_db(2)

func _process(delta: float) -> void:
	sfx_preview_timer-=delta

func sfx_volume_slider_value_changed(value:float):
	AudioServer.set_bus_volume_db(1, value)
	if sfx_preview_timer < 0:
		sfx_preview_timer = SFX_PREVIEW_TIMER_MAX
		sfx_audio_stream_player.play()
func music_volume_slider_value_changed(value:float):
	AudioServer.set_bus_volume_db(2, value)
func mouse_sens_slider_value_changed(value:float):
	Settings.mouse_sensitivity = value
func gfx_slider_value_changed(value:float):
	Settings.gfx_quality = (value as int)
