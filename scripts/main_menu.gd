extends Control

@export var level_scene : PackedScene
@export var test_level_scene : PackedScene
@export var start_game_button : Button

func start_game(): get_tree().change_scene_to_packed(level_scene)
func start_test_level(): get_tree().change_scene_to_packed(test_level_scene)

func _ready() -> void:
	start_game_button.grab_focus()
