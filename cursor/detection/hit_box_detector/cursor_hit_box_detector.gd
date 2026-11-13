class_name CursorHitBoxDetector extends Area3D

#region Public References
@onready var collision_object := %CollisionObject as CollisionPolygon3D
#endregion

#region Private Methods
var _cursor: Cursor
#endregion

#region Public Methods
func update(cursor: Cursor) -> bool:
	if cursor == null:
		push_error("The provided Cursor reference is null!")
		return false
	
	_cursor = cursor
	
	for signal_reference: Signal in [area_entered, area_exited] as Array[Signal]:
		if not signal_reference.is_connected(_on_area_detection):
			if signal_reference.connect(
				_on_area_detection.bind(signal_reference == area_entered)
				) != OK:
					push_error("Signal: %s, could not be connected!" % signal_reference)
					return false
	
	return true


func get_cursor() -> Cursor:
	return _cursor
#endregion

#region Private Methods
func _ready() -> void:
	collision_object.depth = MainConstants.COLLISION_THICKNESS


func _on_area_detection(area: Area3D, state: bool) -> void:
	if not area is EntityHitBoxDetector:
		return
	
	var hit_box_detector := area as EntityHitBoxDetector
	var hit_box: EntityHitBox = hit_box_detector.get_hit_box()
	
	hit_box.set_focused(state)
#endregion
