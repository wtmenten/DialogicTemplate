extends Container
class_name TimelineMetaCard

signal pressed(meta:TimelineMeta)
var timeline_meta: TimelineMeta
var seen = false
@onready var GameController = SceneManager.get_entity(Constants.GameController)

func set_timeline_meta(meta: TimelineMeta):
	timeline_meta = meta
	if Dialogic.History.has_event_been_visited(0, timeline_meta.timeline):
		seen = true
	draw()
	
func draw():
	if timeline_meta.user_label != null and timeline_meta.user_label.length() > 0:
		$VBoxContainer/UserLabel.text = timeline_meta.user_label
	else:
		$VBoxContainer/UserLabel.hide()
		pass
	if seen:
		$VBoxContainer/PanelContainer/TimelineThumbnail.texture = timeline_meta.thumbnail
	else:
		var sbox: StyleBoxFlat = $VBoxContainer/PanelContainer.get_theme_stylebox("panel").duplicate()
		sbox.bg_color = Color("000000", .33)
		$VBoxContainer/PanelContainer.add_theme_stylebox_override("panel", sbox)
	#$VBoxContainer/PanelContainer/TimelineThumbnail.size = Vector2(160, 90)
	#$VBoxContainer/PanelContainer/TimelineThumbnail.update_minimum_size()
	pass

func _ready():
	pass
	#if timeline_meta != null:
		#draw()

# plays hover animation
func _on_mouse_entered() -> void:
	if seen:
		$AnimationPlayer.play("hover")

# plays unhover animation
func _on_mouse_exited() -> void:
	if seen:
		$AnimationPlayer.play_backwards("hover")

# manages left and right click -> emits signals
func _on_gui_input(event:InputEvent) -> void:
	if seen and event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		emit_signal("pressed", timeline_meta)
		GameController.new_game(timeline_meta.timeline, GameController.GameType.TMP)
		
