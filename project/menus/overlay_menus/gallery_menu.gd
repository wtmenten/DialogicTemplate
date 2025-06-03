extends Control

var cg_timeline_metas: Dictionary = {}

@export var TimelineMetaCardScene: PackedScene
@onready var GalleryGrid = $ScrollContainer/GridContainer
@onready var GameController = SceneManager.get_entity(Constants.GameController)
var dirty: bool = true

################################################################################
##								PUBLIC
################################################################################

func _event_visited(_event: DialogicEvent):
	cg_timeline_metas.has(Dialogic.current_timeline.get_identifier())
	if _event.event_sorting_index == 0 and GameController.game_type == GameController.GameType.NORMAL:
		dirty = true


func open() -> void:
	if cg_timeline_metas.size() == 0 or dirty:
		Dialogic.History.load_visited_history()
		draw()
		dirty = false
	show()
	
################################################################################
##								PRIVATE
################################################################################

func _load_timeline_meta_resources():
	cg_timeline_metas = {}
	for file in ResourceLoader.list_directory("res://project/resources/timeline_meta"):
		if file.ends_with(".tres"):
			var meta: TimelineMeta = ResourceLoader.load("res://project/resources/timeline_meta/%s" % file)
			
			if meta.timeline == null:
				push_warning("Timeline Meta Resource without timeline: %s" % file)
				continue
			if meta.timeline_type != TimelineMeta.TimelineType.CG:
				continue
			cg_timeline_metas[meta.timeline.get_identifier()]= meta
			
func draw() -> void:
	var tmp_scene = TimelineMetaCardScene.instantiate()
	await get_tree().process_frame
	GalleryGrid.columns = clamp(roundi(self.size.x / tmp_scene.size.x), 1, 10)
	for child in GalleryGrid.get_children():
		child.queue_free()
	for meta in cg_timeline_metas.values():
		var card: TimelineMetaCard = TimelineMetaCardScene.instantiate()
		card.set_timeline_meta(meta)
		GalleryGrid.add_child(card)
	
func _ready() -> void:
	_load_timeline_meta_resources()
	Dialogic.event_handled.connect(_event_visited)
	hide()
