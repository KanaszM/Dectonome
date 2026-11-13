class_name EntityCursorDetector extends Area3D

#region Constants
const PACK_UID: String = "uid://dww4cvir8qruo"
#endregion

#region Public References
@onready var collision_object := %CollisionObject as CollisionShape3D
#endregion

#region Private Variables
var _radius: float

var _entity: Entity
var _collision_shape: CylinderShape3D
#endregion

#region Public Methods
static func instantiate(entity: Entity, radius: float) -> EntityCursorDetector:
	if entity == null:
		push_error("The provided Entity reference is null!")
		return null
	
	var packed_scene := load(PACK_UID) as PackedScene
	
	if not packed_scene.can_instantiate():
		push_error("EntityCursorDetector scene cannot be instantiated!")
		return null
	
	var instance := packed_scene.instantiate() as EntityCursorDetector
	
	if instance == null:
		push_error("EntityCursorDetector scene instance returned null!")
		return null
	
	instance._entity = entity
	instance._radius = radius
	
	return instance


func update() -> void:
	if collision_object.shape != null and collision_object.shape is CylinderShape3D:
		_collision_shape = collision_object.shape as CylinderShape3D
	
	if _collision_shape == null:
		_collision_shape = CylinderShape3D.new()
		_collision_shape.height = MainConstants.COLLISION_THICKNESS
		collision_object.shape = _collision_shape
	
	_collision_shape.radius = _radius / MainConstants.PIXELS_PER_METER


func get_entity() -> Entity:
	return _entity
#endregion
