extends Control

var save_name = ""
var save_idx = 0
var SaveSlot = preload("res://project/menus/components/save_slot/save_slot.tscn")

@onready var SaveSlotContainer = $Scroll/SaveSlots
@onready var GameController = SceneManager.get_entity(Constants.GameController)
################################################################################
##								PUBLIC
################################################################################

func open() -> void:
	update_saves()
	show()

# will reload and add saves slots
func update_saves() -> void:
	var x = SaveSlot.instantiate()
	await get_tree().process_frame
	SaveSlotContainer.columns = roundi(self.size.x / x.size.x)
	for child in SaveSlotContainer.get_children():
		child.queue_free()
	save_name = ""
	save_idx = 0
	if Dialogic.current_timeline != null:
		x = SaveSlot.instantiate()
		x.set_slot_name("New Save", false)
		var image_texture = ImageTexture.create_from_image(Dialogic.Save.latest_thumbnail)
		x.set_slot_image_texture(image_texture)
		SaveSlotContainer.add_child(x)
		x.pressed.connect(new_save_slot)
	for save in Dialogic.Save.get_slot_names():
		x = SaveSlot.instantiate()
		x.set_slot_name(save, false)
		x.set_slot_image_texture(Dialogic.Save.get_slot_thumbnail(save))
		x.set_extra_info(Dialogic.Save.get_slot_info(save))
		SaveSlotContainer.add_child(x)
		save_name = save.trim_prefix("Save ")
		if save_name.is_valid_int() and save_idx <= int(save_name):
			save_idx = int(save_name) +1
		x.pressed.connect(on_save_slot_pressed)
	

# will save the current state to a new save slot
func new_save_slot(slot_name:String) -> void:
	slot_name = 'Save '+str(save_idx)
	save_idx += 1
	var extra_info = GameController.make_extra_info()
	Dialogic.Save.save(slot_name, false, Dialogic.Save.ThumbnailMode.STORE_ONLY, extra_info)
	GameController.clean_state()
	update_saves()

func _ready():
	hide()

# will overwrite the selected save
func on_save_slot_pressed(slot_name:String) -> void:
	if  Dialogic.current_timeline == null: return
	var extra_info = GameController.make_extra_info()
	Dialogic.Save.save(slot_name, false, Dialogic.Save.ThumbnailMode.STORE_ONLY, extra_info)
	GameController.clean_state()
	update_saves()
