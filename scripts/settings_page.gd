extends Control

class_name SettingsPage

@export var sens_slider : HSlider
@export var gfx_slider : HSlider
@export var sfx_slider : HSlider
@export var music_slider : HSlider
@export var back_button : Button
@export var quit_game_button : Button
@export var is_ingame_menu := false

const SFX_PREVIEW_TIMER_MAX := 0.15
var sfx_preview_timer := SFX_PREVIEW_TIMER_MAX
@export var sfx_audio_stream_player : AudioStreamPlayer

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	back_button.grab_focus()
	sens_slider.value = Settings.mouse_sensitivity
	gfx_slider.value = Settings.gfx_quality
	sfx_slider.value = AudioServer.get_bus_volume_db(1)
	music_slider.value = AudioServer.get_bus_volume_db(2)
	quit_game_button.visible = is_ingame_menu
	if is_ingame_menu:
		back_button.text = "Continue"

func back():
	hide()

func quit_to_main_menu():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

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
	var level = 	get_tree().get_first_node_in_group("level") as Level
	if level: level.update_gfx_settings()
