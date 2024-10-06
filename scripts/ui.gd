extends CanvasLayer
class_name UI

@export var crosshair : ColorRect
@export var kitten_count_label : Label
@export var tardigrade_count_label : Label
@export var sprint_energy_label : Label
@export var kitten_pool_label : Label
@export var time_label : Label
@export var cat_scanner_texture : TextureRect
@export var cat_palm_texture : TextureRect
@export var scan_energy_bar : ProgressBar
@export var spray_energy_bar : ProgressBar
@export var spray_sprite : AnimatedSprite2D
@export var detection_progress_sprite : AnimatedSprite2D
@export var pick_sprite : AnimatedSprite2D
@export var kittens_in_hand: KittensInHand

func update(player:Player):
	cat_palm_texture.visible = !player.scanner_showing
	kitten_count_label.text = "Kittens: %d" % player.kitten_count
	tardigrade_count_label.text = "Tardigrades: %d" % player.tardigrade_count
	kittens_in_hand.kitten_count = player.kitten_count

	scan_energy_bar.value = player.scan_energy
	scan_energy_bar.max_value = player.SCAN_ENERGY_MAX

	spray_energy_bar.value = player.spray_energy
	spray_energy_bar.max_value = player.SPRAY_ENERGY_MAX

	sprint_energy_label.text = "Sprint Energy: %d" % round(player.sprint_energy)

	cat_scanner_texture.visible = player.scanner_showing

	var dl := player.kitten_detection_level as float
	var max_dl := player.KITTEN_DETECTION_LEVEL_MAX as float
	var total_frames := detection_progress_sprite.sprite_frames.get_frame_count(&"default") - 1
	var frame = ((dl as float) / (max_dl as float) * total_frames) as int

	detection_progress_sprite.frame = frame
	if player.kitten_detection_level < player.KITTEN_DETECTION_LEVEL_MAX / 2:
		detection_progress_sprite.frame = detection_progress_sprite.frame + randi_range(-1, 1)

	spray_sprite.visible = player.current_tool == Player.Tool.SPRAYER
	pick_sprite.visible = player.current_tool == Player.Tool.PICKER

	kitten_pool_label.text = "Kitten Pool: %d" % player.kitten_pool
	time_label.text = "Time: %d" % Progress.time_played
