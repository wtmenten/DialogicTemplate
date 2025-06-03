extends Control

@onready var GameController = SceneManager.get_entity(Constants.GameController)
@onready var MenuMusic = $MenuMusic

################################################################################
##								PUBLIC
################################################################################

func open():
	show()
	await get_tree().create_timer(0.2).timeout
	$Buttons/NewGame_Button.grab_focus()

################################################################################
##								PRIVATE
################################################################################

func _ready():
	open()

func _on_new_game_button_pressed() -> void:
	MenuMusic.playing = false
	Dialogic.clear(Dialogic.ClearFlags.FULL_CLEAR)
	$Buttons/NewGame_Button.release_focus()
	GameController.new_game()
	
func _on_load_game_button_pressed():
	hide()
	GameController.OverlayMenu.open_load_menu()

func _on_settings_button_pressed():
	hide()
	GameController.OverlayMenu.open_settings_menu()

func _on_about_button_pressed():
	hide()
	GameController.OverlayMenu.open_about_menu()

func _on_gallery_button_pressed():
	hide()
	GameController.OverlayMenu.open_gallery_menu()

func _on_quit_button_pressed():
	get_tree().quit()
