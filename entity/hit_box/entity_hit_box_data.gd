class_name EntityHitBoxData extends Resource

#region Exports
@export var size: float
@export var position: Vector3
@export var value: int: set = _set_value

@export_group("Cursor Tracking", "cursor_tracking_")
@export var cursor_tracking_enabled: bool
#endregion

#region Private Variables
var _is_disabled: bool
#endregion

#region Public Methods
func is_disabled() -> bool:
	return _is_disabled
#endregion

#region Private Methods
func _init() -> void:
	resource_local_to_scene = true


func _set_value(arg: int) -> void:
	value = maxi(0, arg)
	_is_disabled = value == 0
#endregion
