class_name CursorEntityDetector extends Area3D

#region Public References
@onready var collision_object := %CollisionObject as CollisionShape3D
#endregion

#region Exports
@export_range(0.001, 10.0, 0.001, "or_greater") var radius: float = 1.0: set = _set_radius
#endregion

#region Private Methods
var _cursor: Cursor
var _collision_shape: CylinderShape3D
#endregion

#region Public Methods
func update(cursor: Cursor) -> bool:
	set_physics_process(false)
	
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
	
	_update_collision_shape()
	set_physics_process(true)
	
	return true


func get_cursor() -> Cursor:
	return _cursor
#endregion

#region Private Methods
func _ready() -> void:
	set_physics_process(false)
	_set_radius(radius)


func _physics_process(_delta: float) -> void:
	var entity_was_detected: bool
	
	for area: Area3D in get_overlapping_areas():
		if area is EntityCursorDetector:
			var entity_cursor_detector := area as EntityCursorDetector
			var entity: Entity = entity_cursor_detector.get_entity()
			
			Hub.set_cursor_detected_entity(entity)
			entity_was_detected = true
			break
	
	if not entity_was_detected:
		Hub.set_cursor_detected_entity(null)


func _update_collision_shape() -> void:
	if collision_object.shape != null and collision_object.shape is CylinderShape3D:
		_collision_shape = collision_object.shape as CylinderShape3D
	
	if _collision_shape == null:
		_collision_shape = CylinderShape3D.new()
		_collision_shape.height = MainConstants.COLLISION_THICKNESS
		collision_object.shape = _collision_shape
	
	_collision_shape.radius = radius


func _on_area_detection(area: Area3D, state: bool) -> void:
	if not area is EntityCursorDetector:
		return
	
	var entity: Entity = (area as EntityCursorDetector).get_entity()
	
	for hit_box: EntityHitBox in entity.get_hit_boxes():
		hit_box.set_cursor_tracking(_cursor if state else null)


func _set_radius(arg: float) -> void:
	radius = arg
	
	if is_inside_tree():
		_update_collision_shape()
#endregion
