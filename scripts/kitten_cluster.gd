extends StaticBody3D
class_name KittenCluster

@export var sprite : Sprite3D
var current_reveal_tween : Tween
var fade_out_timer := 15.0

const FADED_OUT_COLOR = Color(1,1,1,0.0)

func _ready() -> void:
	sprite.modulate = FADED_OUT_COLOR;

func retrieve(player:Player):
	if sprite.modulate.a > FADED_OUT_COLOR.a:
		player.kitten_count += 1
		if (randf()) < 0.2: player.tardigrade_count += 1
		queue_free()

func spray(player:Player):
	if current_reveal_tween:
		current_reveal_tween.stop()
		current_reveal_tween = null
	sprite.modulate = Color.WHITE
	current_reveal_tween = get_tree().create_tween()
	current_reveal_tween.tween_property(sprite, "modulate", FADED_OUT_COLOR, fade_out_timer)
