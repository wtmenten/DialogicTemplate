extends HBoxContainer

@onready var GameController = SceneManager.get_entity(Constants.GameController)

func _on_save_button_pressed():
	get_viewport().set_input_as_handled()
	Dialogic.Save.take_thumbnail()
	GameController.OverlayMenu.open_save_menu()

func _on_load_button_pressed():
	get_viewport().set_input_as_handled()
	Dialogic.Save.take_thumbnail()
	GameController.OverlayMenu.open_load_menu()

func _on_settings_button_pressed():
	get_viewport().set_input_as_handled()
	Dialogic.Save.take_thumbnail()
	GameController.OverlayMenu.open_settings_menu()

func _on_history_button_pressed() -> void:
	get_viewport().set_input_as_handled()
	Dialogic.History.close_requested.connect(GameController.resume_game)
	Dialogic.History.resume()
	GameController.pause_game()
	Dialogic.History.open_history()
