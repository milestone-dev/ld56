extends Control

const preloaded_resources = [
	preload("res://assets/materials/SprayBottleParticleProcess.tres"),
	preload("res://assets/materials/spray_draw_pass.tres"),
	preload("res://assets/materials/KittenClusterDrawPass.tres"),
	preload("res://assets/materials/KittenClusterParticleProcess.tres"),
	preload("res://assets/materials/kittens_in_hand_particle_process.tres"),
	preload("res://assets/materials/kittens_in_hand_draw_pass.tres"),
	preload("res://assets/sfx/spray.ogg"),
	preload("res://assets/sfx/purr4.ogg"),
	preload("res://assets/sfx/roombadrive.ogg"),
]

@export var level_scene : PackedScene
@export var test_level_scene : PackedScene
@export var start_game_button : Button
@export var settings_page : Control

func start_game():
	Progress.reset()
	get_tree().change_scene_to_packed(level_scene)

func start_test_level():
	Progress.reset()
	get_tree().change_scene_to_packed(test_level_scene)

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	start_game_button.grab_focus()

func go_to_settings():
	settings_page.show()
