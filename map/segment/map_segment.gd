@tool
class_name MapSegment extends STContainer

#region Constants
const NAME_SIZE_INDICATOR: StringName = &"SizeIndicator"
#endregion

#region Exports
@export var data: MapSegmentData
#endregion

#region Public References
@onready var marker_middle := %MarkerMiddle as Marker3D
#endregion

#region Private Methods
func _ready() -> void:
	if not Engine.is_editor_hint():
		get_node(NodePath(NAME_SIZE_INDICATOR)).free()
	
	super._ready()


#func _physics_process(delta: float) -> void:
	#print(roundf((marker_middle.global_position.z - player.global_position.z)))
#endregion
