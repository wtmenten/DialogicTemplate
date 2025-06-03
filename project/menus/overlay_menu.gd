extends Control

@export var SubMenusContainer: Node

@onready var SaveMenu = $HBoxContainer/MenuContent/SaveMenu
@onready var LoadMenu = $HBoxContainer/MenuContent/LoadMenu
@onready var SettingsMenu = $HBoxContainer/MenuContent/SettingsMenu
@onready var AboutMenu = $HBoxContainer/MenuContent/AboutMenu
@onready var GalleryMenu = $HBoxContainer/MenuContent/GalleryMenu

@onready var MenuTitle = $HBoxContainer/Buttons/MenuTitle

@onready var UnsavedWarning = SceneManager.get_entity(Constants.UnsavedPopup)
@onready var GameController = SceneManager.get_entity(Constants.GameController)


func _ready() -> void:
	hide_submenus()
	hide()

################################################################################
##								PUBLIC
################################################################################

func hide_submenus():
	for child in SubMenusContainer.get_children():
		child.hide()

func open_main_menu():
	hide_submenus()
	hide()
	GameController.main_menu()

func open_save_menu():
	hide_submenus()
	check_game_state()
	MenuTitle.text = "Save Menu"
	$HBoxContainer/Buttons/SaveMenu_Button.grab_focus()
	show()
	SaveMenu.open()

func open_load_menu():
	hide_submenus()
	check_game_state()
	MenuTitle.text = "Load Menu"
	$HBoxContainer/Buttons/LoadMenu_Button.grab_focus()
	show()
	LoadMenu.open()

func open_settings_menu():
	hide_submenus()
	check_game_state()
	MenuTitle.text = "Settings"
	$HBoxContainer/Buttons/Settings_Button.grab_focus()
	show()
	SettingsMenu.open()

func open_about_menu():
	hide_submenus()
	check_game_state()
	MenuTitle.text = "About"
	$HBoxContainer/Buttons/About_Button.grab_focus()
	show()
	AboutMenu.open()
	
func open_gallery_menu():
	hide_submenus()
	check_game_state()
	
	MenuTitle.text = "Gallery"
	$HBoxContainer/Buttons/Gallery_Button.grab_focus()
	show()
	GalleryMenu.open()

# conditional pausing and button visibility
func check_game_state():
	if GameController.is_game_playing():
		GameController.pause_game()
	$HBoxContainer/Buttons/SaveMenu_Button.visible = GameController.game_type == GameController.GameType.NORMAL
	$HBoxContainer/Buttons/Gallery_Button.visible = not GameController.is_game_playing() or GameController.game_type == GameController.GameType.TMP
	$HBoxContainer/Buttons/ResumeGame_Button.visible = GameController.is_game_playing()
	$HBoxContainer/Buttons/HSeparator.visible = GameController.is_game_playing()

################################################################################
##								PRIVATE
################################################################################


## SIGNALS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
func _on_main_menu_button_pressed():
	if GameController.is_game_playing() and GameController.game_state_dirty():
		UnsavedWarning.open(self, "open_main_menu")
	else:
		open_main_menu()

func _on_save_menu_button_pressed():
	open_save_menu()

func _on_load_menu_button_pressed():
	open_load_menu()

func _on_settings_button_pressed():
	open_settings_menu()

func _on_about_button_pressed():
	open_about_menu()
	
func _on_gallery_button_pressed():
	open_gallery_menu()

func _on_quit_button_pressed():
	if GameController.is_game_playing() and GameController.game_state_dirty():
		UnsavedWarning.open(get_tree(), "quit")
	else:
		get_tree().call("quit")

func _on_resume_game_button_pressed():
	hide()
	GameController.resume_game()
