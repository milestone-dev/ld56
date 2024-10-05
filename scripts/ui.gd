extends CanvasLayer
class_name UI

@export var crosshair : ColorRect
@export var kitten_count_label : Label
@export var tardigrade_count_label : Label
@export var sprint_energy_label : Label
@export var kitten_pool_label : Label
@export var time_label : Label
@export var detection_progress_bar : ProgressBar
@export var cat_scanner_texture : TextureRect
@export var cat_palm_texture : TextureRect
@export var scan_energy_bar : ProgressBar
@export var spray_energy_bar : ProgressBar
@export var spray_sprite : AnimatedSprite2D
@export var pick_sprite : AnimatedSprite2D

func update(player:Player):
	cat_palm_texture.visible = !player.scanner_showing
	kitten_count_label.text = "Kittens: %d" % player.kitten_count
	tardigrade_count_label.text = "Tardigrades: %d" % player.tardigrade_count

	scan_energy_bar.value = player.scan_energy
	scan_energy_bar.max_value = player.SCAN_ENERGY_MAX

	spray_energy_bar.value = player.spray_energy
	spray_energy_bar.max_value = player.SPRAY_ENERGY_MAX

	sprint_energy_label.text = "Sprint Energy: %d" % round(player.sprint_energy)

	cat_scanner_texture.visible = player.scanner_showing
	detection_progress_bar.max_value = player.KITTEN_DETECTION_LEVEL_MAX
	detection_progress_bar.value = player.kitten_detection_level
	if player.kitten_detection_level < player.KITTEN_DETECTION_LEVEL_MAX:
		detection_progress_bar.value = player.kitten_detection_level * randf_range(0.95,1.05)

	spray_sprite.visible = player.current_tool == Player.Tool.SPRAYER
	pick_sprite.visible = player.current_tool == Player.Tool.PICKER

	kitten_pool_label.text = "Kitten Pool: %d" % player.kitten_pool
	time_label.text = "Time: %d" % player.play_time
