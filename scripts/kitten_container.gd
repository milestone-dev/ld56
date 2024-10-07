extends StaticBody3D
class_name KittenContainer

@export var label : Label3D

var count := 0

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var glow_cone: Node3D = $glow_cone

var player1 : Player

func interact(player : Player):
	player.kitten_saved_count += player.kitten_count
	player.kitten_count = 0
	player.kitten_disappear_timer = Settings.kitten_drop_timer_max
	update_count(player.kitten_saved_count)
	player1.kitten_picked_up = false
	glow_cone.visible = false
	animation_player.play("interact")

func update_count(count:int):
	label.text = "%d / 1 000 000\nKittens Saved" % count

func _ready() -> void:
	player1 = get_tree().get_first_node_in_group("player") as Player
	glow_cone.visible = false
	update_count(0)

func _process(delta: float) -> void:
	if player1.kitten_picked_up == true:
		
		glow_cone.visible = true
