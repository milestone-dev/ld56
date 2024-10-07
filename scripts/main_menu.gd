extends Control

const a = preload("res://assets/materials/SprayBottleParticleProcess.tres")
const b = preload("res://assets/materials/spray_draw_pass.tres")
const c = preload("res://assets/materials/KittenClusterDrawPass.tres")
const e = preload("res://assets/materials/KittenClusterParticleProcess.tres")
const f = preload("res://assets/materials/kittens_in_hand_particle_process.tres")
const g = preload("res://assets/materials/kittens_in_hand_draw_pass.tres")

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
