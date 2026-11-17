class_name SessionGameData extends Resource

#region Constants
const DEFAULT_NAME: String = "N/A"
#endregion

#region Exports
@export var name: String: get = _get_name
#endregion

#region Public Variables
var id: int
#endregion

#region Public Methods
func get_name_with_id() -> String:
	return "%s (%d)" % [name, id]
#endregion

#region Private Methods
func _init() -> void:
	id = ("%s%s" % [resource_scene_unique_id, name]).hash() + (randi() + 1)


func _get_name() -> String:
	return DEFAULT_NAME if name.is_empty() else name
#endregion
