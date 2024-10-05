extends Control

@export var level_scene : PackedScene
@export var test_level_scene : PackedScene

func start_game(): get_tree().change_scene_to_packed(level_scene)
func start_test_level(): get_tree().change_scene_to_packed(test_level_scene)
