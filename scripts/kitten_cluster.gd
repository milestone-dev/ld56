extends StaticBody3D
class_name KittenCluster

@export var sprite : Sprite3D
@export var label : Label3D
var current_reveal_tween : Tween
var fade_out_timer := 5.0

var kitten_count := 0
const KITTEN_RESPAWN_TIMER_MAX := 5.0
var kitten_respawn_timer := 0.0

const FADED_OUT_COLOR = Color(1,1,1,0.0)

func has_kittens() -> bool:	return kitten_count > 0

func _ready() -> void:
	sprite.modulate = FADED_OUT_COLOR;

func _process(delta: float) -> void:
	kitten_respawn_timer -= delta

func retrieve(player:Player):
	if sprite.modulate.a > FADED_OUT_COLOR.a:
		player.kitten_count += kitten_count
		if (randf()) < 0.2: player.tardigrade_count += 1
		kitten_count = 0
		label.text = "%d" % kitten_count
		if current_reveal_tween: current_reveal_tween.stop()
		sprite.modulate = FADED_OUT_COLOR;
		kitten_respawn_timer = KITTEN_RESPAWN_TIMER_MAX;

func add_kittens(count:int) -> bool:
	if kitten_respawn_timer > 0: return false
	kitten_count += count
	label.text = "%d" % kitten_count
	return true

func spray(player:Player):
	if !has_kittens(): return
	if current_reveal_tween:
		current_reveal_tween.stop()
		current_reveal_tween = null
	sprite.modulate = Color.WHITE
	current_reveal_tween = get_tree().create_tween()
	current_reveal_tween.tween_property(sprite, "modulate", FADED_OUT_COLOR, fade_out_timer)
