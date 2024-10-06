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
@export var pain_flash_rect : TextureRect
@export var settings_menu : SettingsPage

@export var interact_pick_label : Label
@export var interact_deposit_label : Label
@export var interact_charge_spray_label : Label
@export var interact_reset_roomba_label : Label
@export var inteact_use_label : Label

var pain_flash_tween : Tween

func is_menu_open(): return settings_menu.visible

func toggle_ingame_menu():
	settings_menu.visible = !settings_menu.visible
	if settings_menu.visible:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _ready() -> void:
	pain_flash_rect.modulate = Color.TRANSPARENT
	settings_menu.hide()

func flash_pain():
	var time := 0.15
	if pain_flash_tween: pain_flash_tween.stop()
	pain_flash_rect.modulate = Color.WHITE
	pain_flash_tween = get_tree().create_tween()
	pain_flash_tween.tween_property(pain_flash_rect, "modulate", Color.TRANSPARENT, time)

func update(player:Player):

	if !player.current_focused_object:
		interact_pick_label.hide()
		interact_deposit_label.hide()
		interact_charge_spray_label.hide()
		interact_reset_roomba_label.hide()
		inteact_use_label.hide()
	else:
		if player.current_focused_object is KittenCluster:
			interact_pick_label.show()
		elif player.current_focused_object is KittenContainer:
			interact_deposit_label.show()
		elif player.current_focused_object is SprayRecharger:
			interact_charge_spray_label.show()
		elif player.current_focused_object is Roomba:
			interact_reset_roomba_label.show()
		else:
			inteact_use_label.show()



	kittens_in_hand.visible = player.kitten_count > 0
	cat_palm_texture.visible = !player.scanner_showing
	kitten_count_label.visible = player.kitten_count > 0
	kitten_count_label.text = "%d" % player.kitten_count
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
	if player.kitten_detection_level > 0 and player.kitten_detection_level < player.KITTEN_DETECTION_LEVEL_MAX / 2:
		detection_progress_sprite.frame = detection_progress_sprite.frame + randi_range(-1, 1)

	spray_sprite.visible = player.current_tool == Player.Tool.SPRAYER
	pick_sprite.visible = player.current_tool == Player.Tool.PICKER

	kitten_pool_label.text = "Kitten Pool: %d Kittens Saved %d" % [player.kitten_pool, player.kitten_saved_count]
	time_label.text = "Time: %d. Drop timer: %d" % [Progress.time_played, player.kitten_disappear_timer]
