extends Node

#region Signals
signal cursor_set
signal cursor_removed
signal cursor_updated(state: bool)
signal cursor_entity_detection_changed

#signal entity_scene_set
#signal entity_scene_removed
#signal entity_scene_updated(state: bool)
#endregion

#region Public References
var cursor: Cursor
var cursor_detected_entity: Entity

var entity_scene: EntityScene
#endregion

#region Public Methods
func set_cursor(cursor_reference: Cursor) -> void:
	if cursor_reference == null and cursor != null:
		cursor = null
		cursor_removed.emit()
		return
	
	if cursor_reference != cursor:
		cursor = cursor_reference
		
		if not cursor.updater.updated.is_connected(_on_cursor_updated):
			cursor.updater.updated.connect(_on_cursor_updated)
		
		cursor_set.emit()


func set_cursor_detected_entity(entity_reference: Entity) -> void:
	if entity_reference != cursor_detected_entity:
		cursor_detected_entity = entity_reference
		cursor_entity_detection_changed.emit()


#func set_entity_scene(entity_scene_reference: EntityScene) -> void:
	#if entity_scene_reference == null and entity_scene != null:
		#entity_scene = null
		#entity_scene_removed.emit()
		#return
	#
	#if entity_scene_reference != entity_scene:
		#entity_scene = entity_scene_reference
		#
		#if not entity_scene.updater.updated.is_connected(_on_entity_scene_updated):
			#entity_scene.updater.updated.connect(_on_entity_scene_updated)
		#
		#entity_scene_set.emit()
#endregion

#region Private Methods
func _on_cursor_updated(state: bool) -> void:
	cursor_updated.emit(state)


#func _on_entity_scene_updated(state: bool) -> void:
	#entity_scene_updated.emit(state)
#endregion
