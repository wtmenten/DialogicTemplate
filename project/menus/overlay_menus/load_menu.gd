extends Control

var SaveSlot = preload("res://project/menus/components/save_slot/save_slot.tscn")

@onready var SaveSlotContainer = $Scroll/SaveSlots
@onready var MenusContainer = get_parent().get_parent().get_parent()
@onready var SubMenus = get_parent().get_parent()
@onready var GameController = SceneManager.get_entity(Constants.GameController)
@onready var UnsavedWarning = SceneManager.get_entity(Constants.UnsavedPopup)
@onready var DeleteSaveWarning = SceneManager.get_entity(Constants.DeleteSavePopup)

var current_selected_slot

################################################################################
##								PUBLIC
################################################################################

func open() -> void:
	show()
	update_saves()

# will reload and add saves slots
func update_saves() -> void:
	var x = SaveSlot.instantiate()
	await get_tree().process_frame
	SaveSlotContainer.columns = roundi(self.size.x / x.size.x)
	for child in SaveSlotContainer.get_children():
		child.queue_free()
	for slot_name in Dialogic.Save.get_slot_names():
		x = SaveSlot.instantiate()
		x.set_slot_name(slot_name)
		x.set_slot_image_texture(Dialogic.Save.get_slot_thumbnail(slot_name))
		x.set_extra_info(Dialogic.Save.get_slot_info(slot_name))
		SaveSlotContainer.add_child(x)
		x.pressed.connect(save_slot_pressed)
		x.delete_requested.connect(save_slot_delete_request)


# will load the currently selected slot
func load_slot() -> void:
	GameController.load_game(current_selected_slot)

################################################################################
##								PRIVATE
################################################################################

func _ready() -> void:
	hide()

# will load the slot @save_slot_name or show a warning
func save_slot_pressed(save_slot_name:String) -> void:
	current_selected_slot = save_slot_name
	if GameController.is_game_playing() and GameController.game_state_dirty():
		UnsavedWarning.open(self, "load_slot")
	else:
		load_slot()

# will show a warning about deleting saves
func save_slot_delete_request(save_slot_name:String) -> void:
	current_selected_slot = save_slot_name
	DeleteSaveWarning.open(self, "delete_save_slot")

# will delete the currently selected save slot
func delete_save_slot() -> void:
	Dialogic.Save.delete_slot(current_selected_slot)
	update_saves()
