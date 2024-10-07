extends Control

@export var stat_1_t : Label
@export var stat_1_d : Label

@export var stat_2_t : Label
@export var stat_2_d : Label

@export var stat_3_t : Label
@export var stat_3_d : Label

@export var stat_4_t : Label
@export var stat_4_d : Label

@export var stat_5_t : Label
@export var stat_5_d : Label

@export var stat_6_t : Label
@export var stat_6_d : Label

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	var time_in_sec : int = Progress.time_played as int
	var seconds = time_in_sec%60
	var minutes = (time_in_sec/60)%60
	var hours = (time_in_sec/60)/60
	stat_1_d.text = "%02dh %02dm %02ds" % [hours, minutes, seconds]

	stat_2_d.text = "%d" % Progress.kittens_picked_up

	stat_3_d.text = "%d" % Progress.kittens_leaked

	stat_4_d.text = "%d" % Progress.roombas_sent_home

func continue_clicked():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
