extends CanvasLayer
class_name UI

@export var crosshair : ColorRect
@export var kitten_count_label : Label
@export var tardigrade_count_label : Label
@export var current_tool_label : Label
@export var scan_energy_label : Label
@export var spray_energy_label : Label
@export var kitten_pool_label : Label
@export var time_label : Label
@export var detection_progress_bar : ProgressBar

func update(player:Player):
	kitten_count_label.text = "Kittens: %d" % player.kitten_count
	tardigrade_count_label.text = "Tardigrades: %d" % player.tardigrade_count


	scan_energy_label.text = "Scan Energy: %d" % round(player.scan_energy)
	spray_energy_label.text = "Spray Energy: %d" % round(player.spray_energy)

	current_tool_label.text = Player.Tool.keys()[player.current_tool]

	detection_progress_bar.visible = player.scanner_showing
	detection_progress_bar.max_value = player.KITTEN_DETECTION_LEVEL_MAX
	detection_progress_bar.value = player.kitten_detection_level

	kitten_pool_label.text = "Kitten Pool: %d" % player.kitten_pool
	time_label.text = "Play Time: %d" % player.play_time
