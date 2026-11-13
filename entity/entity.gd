class_name Entity extends Node3D

#region Constants
const PACK_UID: String = "uid://boaossxu2bry5"
#endregion

#region Exports
@export_file("*.tscn") var preset_file: String
#endregion

#region Public References
@onready var updater: Updater = Updater.new(self, [
	_update_step_base_check,
	_update_step_add_preset,
	_update_step_remove_sprites,
	_update_step_add_sprites,
	_update_step_remove_hit_boxes,
	_update_step_add_hit_boxes,
	_update_step_update_hit_boxes,
	_update_step_remove_cursor_detector,
	_update_step_add_cursor_detector,
	_update_step_update_cursor_detector,
	_update_step_remove_preset,
	_update_step_posr_initialization,
	])

@onready var sprites_container := %SpritesContainer as Node3D
@onready var hit_boxes_container := %HitBoxesContainer as Node3D
#endregion

#region Private Variables
var _preset: EntityPresetBase
var _preset_data: EntityPresetBaseData
var _hit_boxes: Array[EntityHitBox]
var _cursor_detector: EntityCursorDetector

var _hit_box_update_count_max: int
var _hit_box_update_count_failed: int
var _hit_box_update_count_current: int
var _hit_box_values_max: int
var _hit_box_values_current: int

var _update_step_post_initialization_passed: bool
#endregion

#region Public Methods
static func instantiate(preset_file_path: String = "") -> Entity:
	var packed_scene := load(PACK_UID) as PackedScene
	
	if not packed_scene.can_instantiate():
		push_error("Entity scene cannot be instantiated!")
		return null
	
	var instance := packed_scene.instantiate() as Entity
	
	if instance == null:
		push_error("Entity scene instance returned null!")
		return null
	
	instance.preset_file = preset_file_path
	
	return instance


func get_preset_data() -> EntityPresetBaseData:
	return _preset_data


func get_hit_boxes() -> Array[EntityHitBox]:
	return _hit_boxes


func get_total_hit_boxes_value() -> int:
	var total: int = 0
	
	for hit_box: EntityHitBox in _hit_boxes:
		total += hit_box.data.value
	
	return total


func get_hit_box_values_max() -> int:
	return _hit_box_values_max


func get_hit_box_values_current() -> int:
	return _hit_box_values_current
#endregion

#region Update Methods
func _update_step_base_check() -> void:
	if not is_inside_tree():
		updater.abort("This Entity is not inside the SceneTree!")
		return
	
	updater.proceed()


func _update_step_add_preset() -> void:
	if preset_file.is_empty():
		updater.abort("Missing EntityPresetBase!")
		return
	
	for child: Node in get_children():
		if child is EntityPresetBase:
			_preset = child as EntityPresetBase
			_preset_data = _preset.data
			break
	
	if _preset != null:
		updater.proceed()
		return
	
	_preset = EntityPresetBase.instantiate(self, preset_file)
	
	if _preset == null:
		updater.abort()
		return
	
	_preset_data = _preset.data
	Utils.add_node_and_execute(self, _preset, updater.proceed)


func _update_step_remove_sprites() -> void:
	Utils.remove_nodes_and_execute(sprites_container, updater.proceed)


func _update_step_add_sprites() -> void:
	var sprites_3d: Array[Sprite3D] = _preset.get_3d_sprites()
	
	if sprites_3d.is_empty():
		updater.abort("No sprites could be found on preset: %s!" % _preset.scene_file_path)
		return
	
	Utils.add_nodes_and_execute(
		sprites_container, Array(sprites_3d, TYPE_OBJECT, &"Node", Node), updater.proceed
		)


func _update_step_remove_hit_boxes() -> void:
	Utils.remove_nodes_and_execute(hit_boxes_container, func() -> void:
		_hit_boxes.clear()
		updater.proceed()
		)


func _update_step_add_hit_boxes() -> void:
	_hit_boxes = _preset.get_hit_boxes()
	
	if _hit_boxes.is_empty():
		updater.abort("No hit boxes could be found on preset: %s!" % _preset.scene_file_path)
		return
	
	Utils.add_nodes_and_execute(
		hit_boxes_container,
		Array(_hit_boxes, TYPE_OBJECT, &"Node", Node),
		updater.proceed
		)


func _update_step_update_hit_boxes() -> void:
	var func_on_hit_box_updated: Callable = func(state: bool) -> void:
		_hit_box_update_count_current += 1
		
		if not state:
			_hit_box_update_count_failed += 1
		
		if _hit_box_update_count_current == _hit_box_update_count_max:
			if _hit_box_update_count_failed != 0:
				updater.abort("EntityHitBox failed to update %d / %d!" % [
					_hit_box_update_count_failed, _hit_box_update_count_current
					])
			
			else:
				updater.proceed()
	
	_hit_box_update_count_max = hit_boxes_container.get_child_count()
	_hit_box_update_count_failed = 0
	_hit_box_update_count_current = 0
	
	for child: Node in hit_boxes_container.get_children():
		var hit_box := child as EntityHitBox
		
		hit_box.updater.updated.connect(func_on_hit_box_updated, CONNECT_ONE_SHOT)
		hit_box.updater.start()


func _update_step_remove_cursor_detector() -> void:
	for child: Node in get_children():
		if child is EntityCursorDetector:
			_cursor_detector = child as EntityCursorDetector
			break
	
	if _cursor_detector == null:
		updater.proceed()
		return
	
	var func_on_cursor_detector_tree_exited: Callable = func() -> void:
		_cursor_detector = null
		updater.proceed()
	
	_cursor_detector.tree_exited.connect(func_on_cursor_detector_tree_exited, CONNECT_ONE_SHOT)
	_cursor_detector.queue_free()


func _update_step_add_cursor_detector() -> void:
	var func_on_cursor_detector_ready: Callable = func() -> void:
		updater.proceed()
	
	_cursor_detector = _preset.get_cursor_detector()
	
	if _cursor_detector == null:
		updater.abort()
		return
	
	_cursor_detector.ready.connect(func_on_cursor_detector_ready, CONNECT_ONE_SHOT)
	add_child(_cursor_detector)


func _update_step_update_cursor_detector() -> void:
	_cursor_detector.update()
	updater.proceed()


func _update_step_remove_preset() -> void:
	var func_execution_callback: Callable = func() -> void:
		_preset = null
		updater.proceed()
	
	Utils.remove_node_and_execute(_preset, func_execution_callback)


func _update_step_posr_initialization() -> void:
	if _update_step_post_initialization_passed:
		updater.proceed()
		return
	
	var total_hit_boxes_value: int = get_total_hit_boxes_value()
	
	_hit_box_values_max = total_hit_boxes_value
	_hit_box_values_current = total_hit_boxes_value
	
	_update_step_post_initialization_passed = true
	updater.proceed()
#endregion
