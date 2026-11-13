class_name CursorPresetBaseData extends Resource

#region Enums
enum TargetMode {FRONT, BACK}
enum RotationMode {FREEFORM, SPRITE_CENTER_FOCUSED}
#endregion

#region Export
@export_group("Target", "target_")
@export var target_mode: TargetMode

@export_group("Move", "move_")
@export var move_enabled: bool = true
@export_range(0.0, 100.0, 0.001, "or_greater") var move_speed: float = 12.0
@export_range(0.0, 50.0, 0.001, "or_greater") var move_acceleration: float = 8.0
@export_range(0.0, 50.0, 0.001, "or_greater") var move_friction: float = 12.0

@export_group("Rotation", "rotation_")
@export var rotation_mode: RotationMode = RotationMode.SPRITE_CENTER_FOCUSED
@export_range(0.0, 100.0, 0.001, "or_greater") var rotation_speed: float = 12.0
@export_range(0.0, 50.0, 0.001, "or_greater") var rotation_acceleration: float = 8.0
@export_range(0.0, 50.0, 0.001, "or_greater") var rotation_friction: float = 12.0
#endregion

#region Public Methods
func target_mode_is_front() -> bool:
	return target_mode == TargetMode.FRONT
#endregion
