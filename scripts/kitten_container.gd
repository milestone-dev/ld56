extends StaticBody3D
class_name KittenContainer

@export var label : Label3D

var count := 0

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func interact(player : Player):
	player.kitten_saved_count += player.kitten_count
	player.kitten_count = 0
	player.kitten_disappear_timer = Settings.kitten_drop_timer_max
	update_count(player.kitten_saved_count)
	
	animation_player.play("interact")

func update_count(count:int):
	label.text = "%d / 1 000 000\nKittens Saved" % count

func _ready() -> void:
	update_count(0)
