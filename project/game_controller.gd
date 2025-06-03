extends Node

@export var GameContainer: Node
@export var MenuContainer: Node
@export var MainMenuScene: PackedScene
@export var OverlayMenuScene: PackedScene
@export var PopupsScene: PackedScene
@export var InGameMenuScene: PackedScene

@export var starting_timeline: DialogicTimeline

@onready var MenuAnimations: AnimationMixer = $CanvasLayer/MenuAnimations

var MainMenu: Node
var OverlayMenu: Node
var InGameMenu: Node
var Popups: Node
var dirty_state: bool
var pause_dirty_update: bool

enum GameType {NORMAL, TMP}
var game_type: GameType = GameType.NORMAL

func _ready():
	validate_exports()
	Popups = PopupsScene.instantiate()
	#Popups.set_z_index(4)
	MainMenu = MainMenuScene.instantiate()
	OverlayMenu = OverlayMenuScene.instantiate()
	#OverlayMenu.set_z_index(1)
	MenuContainer.add_child(Popups)
	SceneManager._set_singleton_entities()
	MenuContainer.add_child(MainMenu)
	SceneManager._set_singleton_entities()
	MenuContainer.add_child(OverlayMenu)
	SceneManager._set_singleton_entities()


# look for right click input to show the SAVE MENU
func _input(event):
	var is_right_click_event = event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT
	if is_right_click_event and is_game_playing():
		if not (MainMenu and MainMenu.visible or OverlayMenu and OverlayMenu.visible):
			Dialogic.Save.take_thumbnail()
			pause_game()
			InGameMenu.hide()
			if game_type == GameType.NORMAL:
				OverlayMenu.open_save_menu()
			else:
				OverlayMenu.open_gallery_menu()
		elif (MainMenu.visible or OverlayMenu.visible):
			OverlayMenu.hide_current()
			OverlayMenu.hide()
			InGameMenu.show()
			resume_game()

func validate_exports():
	assert(GameContainer != null, "ERROR: provide a GameContainer Node to the GameController")
	assert(MenuContainer != null, "ERROR: provide a MenuContainer Node to the GameController")
	assert(MainMenuScene != null, "ERROR: provide a MainMenuScene Node to the GameController")
	assert(OverlayMenuScene != null, "ERROR: provide a OverlayMenuScene Node to the GameController")
	assert(PopupsScene != null, "ERROR: provide a PopupsScene Node to the GameController")
	assert(InGameMenuScene != null, "ERROR: provide a InGameMenuScene Node to the GameController")

func new_game(timeline: DialogicTimeline = starting_timeline, game_type: GameType = GameType.NORMAL):
	#if timeline == null:
		#timeline = starting_timeline
	end_game()
	var scene = Dialogic.start(timeline.get_identifier(), 0)
	init_game()
	if game_type == GameType.TMP:
		self.game_type = GameType.TMP
		Dialogic.Save.autosave_enabled = false
	scene.process_mode = Node.PROCESS_MODE_ALWAYS


func load_game(slot_name):
	end_game()
	var scene: Node = null
	if !Dialogic.Styles.has_active_layout_node():
		scene = Dialogic.Styles.load_style()
	else:
		scene = Dialogic.Styles.get_layout_node()
		scene.show()
	if not scene.is_node_ready():
		await scene.ready
	pause_dirty_update = true
	Dialogic.Save.load(slot_name)
	scene.process_mode = Node.PROCESS_MODE_ALWAYS
	init_game()
	await get_tree().process_frame
	pause_dirty_update = false
	
func init_game():
	MenuAnimations.play("Fade")
	# get_node(Game).add_child(node)
	Dialogic.timeline_ended.connect(_on_game_ended)
	Dialogic.event_handled.connect(_on_event_handled)
	Dialogic.Save.saved.connect(_on_dialogic_save)
	Dialogic.Save.autosave_enabled = true
	var settingsMenu = SceneManager.get_entity(Constants.SettingsMenu)
	if settingsMenu != null:
		settingsMenu.init()
	game_type = GameType.NORMAL
	await MenuAnimations.animation_finished
	if MainMenu:
		MainMenu.queue_free()
	InGameMenu = InGameMenuScene.instantiate()
	MenuContainer.add_child(InGameMenu)
	
	InGameMenu.show()
	OverlayMenu.hide()
	MenuAnimations.play_backwards("Fade")
	resume_game()

func end_game() -> void:
	Dialogic.clear(Dialogic.ClearFlags.FULL_CLEAR)
	if Dialogic.timeline_ended.is_connected(_on_game_ended):
		Dialogic.timeline_ended.disconnect(_on_game_ended)
	if Dialogic.event_handled.is_connected(_on_event_handled):
		Dialogic.event_handled.disconnect(_on_event_handled)
	if Dialogic.Save.saved.is_connected(_on_dialogic_save):
		Dialogic.Save.saved.disconnect(_on_dialogic_save)
		
	if Dialogic.Styles.has_active_layout_node():
		var scene = Dialogic.Styles.load_style()
		scene.queue_free()
	clean_state()
	if InGameMenu != null:
		InGameMenu.queue_free()
	if OverlayMenu != null:
		OverlayMenu.hide()
	

func is_game_playing() -> bool:
	return Dialogic.current_timeline != null

func game_state_dirty() -> bool:
	return dirty_state

func pause_game():
	#if MainMenu != null:
		#MainMenu.get_node("$MenuMusic").playing = true
	get_tree().paused = true

func resume_game():
	#if MainMenu != null:
		#MainMenu.get_node("$MenuMusic").playing = false
	get_tree().paused = false

func main_menu():
	end_game()
	if MainMenu == null or MainMenu.is_queued_for_deletion():
		MainMenu = MainMenuScene.instantiate()
		MenuContainer.add_child(MainMenu)
		MainMenu.MenuMusic.play()
	MenuAnimations.play_backwards("Fade")
	MainMenu.show()
	await get_tree().create_timer(0.2).timeout

func clean_state():
	dirty_state = false
	
func make_extra_info():
	return {
		"datetime": Time.get_datetime_string_from_system()
	}
	
func _on_dialogic_save(save_info: Dictionary):
	var slot = save_info["slot_name"]
	var is_auto = save_info["is_autosave"]
	if is_auto:
		var extra_info = make_extra_info()
		Dialogic.Save.save(slot, false, Dialogic.Save.ThumbnailMode.STORE_ONLY, extra_info)

func _on_event_handled(_event):
	if not pause_dirty_update and game_type != GameType.TMP:
		dirty_state = true

func _on_game_ended():
	Dialogic.timeline_ended.disconnect(_on_game_ended)
	main_menu()
