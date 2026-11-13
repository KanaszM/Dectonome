class_name Cursor extends Node3D

#region Constants
const PACK_UID: String = "uid://diq6du54xebm"
#endregion

#region Exports
@export_file("*.tscn") var preset_file: String
#endregion

#region Public References
@onready var updater: Updater = Updater.new(self, [
	_update_step_base_check,
	_update_step_remove_preset,
	_update_step_add_preset,
	_update_step_update_preset,
	])
#endregion

#region Private Variables
var _preset: CursorPresetBase
#endregion

#region Public Methods
static func instantiate(preset_file_path: String = "") -> Cursor:
	var packed_scene := load(PACK_UID) as PackedScene
	
	if not packed_scene.can_instantiate():
		push_error("Cursor scene cannot be instantiated!")
		return null
	
	var instance := packed_scene.instantiate() as Cursor
	
	if instance == null:
		push_error("Cursor scene instance returned null!")
		return null
	
	instance.preset_file = preset_file_path
	
	return instance


func get_preset() -> CursorPresetBase:
	return _preset


func get_preset_data() -> CursorPresetBaseData:
	return null if _preset == null else _preset.data
#endregion

#region Update Methods
func _update_step_base_check() -> void:
	if not is_inside_tree():
		updater.abort("This Cursor is not inside the SceneTree!")
		return
	
	updater.proceed()


func _update_step_remove_preset() -> void:
	for child: Node in get_children():
		if child is CursorPresetBase:
			_preset = child as CursorPresetBase
			break
	
	if _preset == null:
		updater.proceed()
		return
	
	Utils.remove_node_and_execute(_preset, func() -> void:
		_preset = null
		updater.proceed()
		)


func _update_step_add_preset() -> void:
	if preset_file.is_empty():
		push_warning("No Cursor preset file path was provided.")
		updater.proceed()
		return
	
	_preset = CursorPresetBase.instantiate(self, preset_file)
	
	if _preset == null:
		updater.abort()
		return
	
	Utils.add_node_and_execute(self, _preset, updater.proceed)


func _update_step_update_preset() -> void:
	_preset.updater.updated.connect(updater.proceed_or_abort, CONNECT_ONE_SHOT)
	_preset.updater.start()
#endregion
