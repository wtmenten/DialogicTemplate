extends Control

signal pressed(slot_name)
signal delete_requested(slot_name)

@onready var labelNode = $VBoxContainer/HBoxContainer/Label
@onready var deleteBtnNode = $VBoxContainer/HBoxContainer/Delete
@onready var imageNode = $VBoxContainer/Panel/Border/Image
@onready var DatetimeNode = $VBoxContainer/Datetime


var extra_info = {}
################################################################################
##								PUBLIC
################################################################################

# sets the text of the save slot and tries to find the thumbnail
func set_slot_name(text:String, enable_delete = true) -> void:
	# set the text
	await self.ready
	labelNode.text = text
	
	if not enable_delete:
		deleteBtnNode.hide()

# sets the tumbnail image for the slot
func set_slot_image_texture(texture: ImageTexture) -> void:
	await self.ready
	await get_tree().process_frame
	imageNode.size.x = self.size.x
	imageNode.size.y = self.size.y
	imageNode.texture = texture
	
func set_extra_info(info_dict):
	extra_info = info_dict
	
################################################################################
##								PRIVATE
################################################################################

func _ready():
	if extra_info.has(Constants.SAVE_DATETIME):
		DatetimeNode.text = extra_info[Constants.SAVE_DATETIME]

# manages left and right click -> emits signals
func _on_SaveSlot_gui_input(event:InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		emit_signal("pressed", labelNode.text)


# plays hover animation
func _on_SaveSlot_mouse_entered() -> void:
	$hoveranims.play("hover")

# plays unhover animation
func _on_SaveSlot_mouse_exited() -> void:
	$hoveranims.play_backwards("hover")


func _on_Delete_mouse_entered():
	var t = create_tween()
	t.set_ease(Tween.EASE_IN_OUT)
	t.set_trans(Tween.TRANS_LINEAR)
	t.tween_property(imageNode, "self_modulate", Color(0.855469, 0.590954, 0.357559), 0.2)
	t.play()


func _on_Delete_mouse_exited():
	var t = create_tween()
	t.set_ease(Tween.EASE_IN_OUT)
	t.set_trans(Tween.TRANS_LINEAR)
	t.tween_property(imageNode, "self_modulate", Color(1, 1, 1), 0.2)
	t.play()

func _on_Delete_pressed():
	delete_requested.emit(labelNode.text)
