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
@export var crosshair_rect : TextureRect

@export var kitten_hold_timer_progress_bar : TextureProgressBar

@export var interact_pick_label : Label
@export var interact_deposit_label : Label
@export var interact_charge_spray_label : Label
@export var interact_reset_roomba_label : Label
@export var inteact_use_label : Label
@export var warning_spray_label : Label
@export var warning_drop_label : Label

@export var hint_scan_label : Label
@export var hint_spray_label : Label
@export var hint_return_label : Label

var has_hinted_scan := false
var has_hinted_spray := false
var has_hinted_return := false

var pain_flash_tween : Tween
var warning_oos_tween : Tween
var warning_drop_tween : Tween

func is_menu_open(): return settings_menu.visible

func toggle_ingame_menu():
	settings_menu.visible = !settings_menu.visible
	if settings_menu.visible:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _ready() -> void:
	pain_flash_rect.modulate = Color.TRANSPARENT
	warning_spray_label.modulate = Color.TRANSPARENT
	warning_drop_label.modulate = Color.TRANSPARENT
	warning_spray_label.show()
	warning_drop_label.show()
	settings_menu.hide()
	hint_scan_label.hide()
	hint_spray_label.hide()
	hint_return_label.hide()
	get_tree().create_timer(2).timeout.connect(hint_scan)

func hint_scan():
	if has_hinted_scan: return
	hint_scan_label.show()
	has_hinted_scan = true

func hint_spray():
	if has_hinted_spray: return
	hint_scan_label.hide()
	hint_spray_label.show()
	has_hinted_spray = true

func hint_return():
	if has_hinted_return: return
	hint_scan_label.hide()
	hint_spray_label.hide()
	hint_return_label.show()
	has_hinted_return = true

func end_hints():
	hint_scan_label.hide()
	hint_spray_label.hide()
	hint_return_label.hide()

func flash_pain():
	var time := 0.15
	if pain_flash_tween: pain_flash_tween.stop()
	pain_flash_rect.modulate = Color.WHITE
	pain_flash_tween = get_tree().create_tween()
	pain_flash_tween.tween_property(pain_flash_rect, "modulate", Color.TRANSPARENT, time)

func flash_kitten_drop():
	var time := 1.5
	if warning_drop_tween: warning_drop_tween.stop()
	warning_drop_label.modulate = Color.WHITE
	warning_drop_tween = get_tree().create_tween()
	warning_drop_tween.tween_property(warning_drop_label, "modulate", Color.TRANSPARENT, time)

func flash_oos():
	var time := 1.5
	if warning_oos_tween: warning_oos_tween.stop()
	warning_spray_label.modulate = Color.WHITE
	warning_oos_tween = get_tree().create_tween()
	warning_oos_tween.tween_property(warning_spray_label, "modulate", Color.TRANSPARENT, time)

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




	crosshair_rect.visible = player.kitten_count == 0
	kittens_in_hand.visible = player.kitten_count > 0
	kitten_hold_timer_progress_bar.visible = player.kitten_count > 0
	kitten_hold_timer_progress_bar.max_value = Settings.kitten_drop_timer_max
	kitten_hold_timer_progress_bar.value = player.kitten_disappear_timer
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

	kitten_pool_label.text = "Kitten Pool: %d Kittens Saved %d Drop timer: %d" % [player.kitten_pool, player.kitten_saved_count,  player.kitten_disappear_timer]

	var time_in_sec : int = Progress.time_played as int
	var seconds = time_in_sec%60
	var minutes = (time_in_sec/60)%60
	var hours = (time_in_sec/60)/60
	time_label.text =  "%02dh %02dm %02ds" % [hours, minutes, seconds]
