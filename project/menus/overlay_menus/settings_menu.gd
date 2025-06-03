extends MarginContainer

@onready var volumeSliderNode = $HBox/VBox/HBoxContainer/OverallVolume/Slider
@onready var muteCheckboxNode = $HBox/VBox/HBoxContainer/Mute/CheckBox
@onready var skipSeenTextCheckboxNode = $HBox/VBox/SkipSeenText/CheckBox
@onready var skipUnseenTextCheckboxNode = $HBox/VBox/SkipUnseenText/CheckBox
@onready var autoAdvanceCheckboxNode = $HBox/VBox/AutoAdvance/CheckBox
@onready var textSpeedSliderNode = $HBox/VBox/TextSpeed/HBoxContainer/HSlider

var KEY_MUTED = "volume_muted"
var KEY_VOLUME_MASTER = "volume_master"
var KEY_TEXT_SPEED = "text_speed"
var KEY_SKIP_SEEN_TEXT = "skip_seen_text"
var KEY_SKIP_UNSEEN_TEXT = "skip_unseen_text"
var KEY_AUTO_ADVANCE = "auto_advance"
var auto_skip_module: DialogicAutoSkip
var auto_advance_module: DialogicAutoAdvance
################################################################################
##								PUBLIC
################################################################################

func open() -> void:
	show()
	
################################################################################
##								PRIVATE
################################################################################
func init() -> void:
	Dialogic.Settings.clear_game_state()
	var inputs = DialogicUtil.autoload().Inputs
	auto_skip_module = inputs.auto_skip
	auto_advance_module = inputs.auto_advance
	
	var master_idx = AudioServer.get_bus_index("Master")
	var vol_master = Dialogic.Save.get_global_info(KEY_VOLUME_MASTER, db_to_linear(AudioServer.get_bus_volume_db(master_idx)))
	var muted = Dialogic.Save.get_global_info(KEY_MUTED, false)
	
	AudioServer.set_bus_mute(master_idx, bool(muted))
	AudioServer.set_bus_volume_db(master_idx, linear_to_db(vol_master))
	
	volumeSliderNode.value = vol_master
	muteCheckboxNode.button_pressed = bool(muted)
	
	skipSeenTextCheckboxNode.button_pressed = Dialogic.Settings.get_setting(KEY_SKIP_SEEN_TEXT, Dialogic.Save.get_global_info(KEY_SKIP_SEEN_TEXT, false))
	skipUnseenTextCheckboxNode.button_pressed = Dialogic.Settings.get_setting(KEY_SKIP_UNSEEN_TEXT, Dialogic.Save.get_global_info(KEY_SKIP_UNSEEN_TEXT, false))
	autoAdvanceCheckboxNode.button_pressed = Dialogic.Settings.get_setting(KEY_AUTO_ADVANCE, Dialogic.Save.get_global_info(KEY_AUTO_ADVANCE, false))
	
	var txt_speed = Dialogic.Settings.get_setting(KEY_TEXT_SPEED, Dialogic.Save.get_global_info(KEY_TEXT_SPEED, 1))
	textSpeedSliderNode.value = txt_speed
	Dialogic.Settings.text_speed = txt_speed
	
func _ready() -> void:
	init()
	hide()


func _on_volume_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value))
	Dialogic.Save.set_global_info(KEY_VOLUME_MASTER, value)
	volumeSliderNode.release_focus()
	
func _on_mute_button_toggled(value):
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), value)
	Dialogic.Save.set_global_info(KEY_MUTED, value)
	
func _on_skip_seen_button_toggled(value):
	Dialogic.Save.set_global_info(KEY_SKIP_SEEN_TEXT, value)
	auto_skip_module.enable_on_visited = value
	
func _on_skip_unseen_button_toggled(value):
	Dialogic.Save.set_global_info(KEY_SKIP_UNSEEN_TEXT, value)
	auto_skip_module.enabled = value
	
func _on_advance_button_toggled(value):
	Dialogic.Save.set_global_info(KEY_AUTO_ADVANCE, value)
	auto_advance_module.enabled_forced = value
	#ProjectSettings.set_setting('dialogic/text/autoadvance_enabled', value)
	
func _on_text_speed_value_changed(value):
	var c = clamp(value, 0.1, 10)
	Dialogic.Settings.text_speed = c
	Dialogic.Save.set_global_info(KEY_TEXT_SPEED, c)
	textSpeedSliderNode.release_focus()

func _on_DisplaySelect_item_selected(index):
	if index == 0:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	if index == 1:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
