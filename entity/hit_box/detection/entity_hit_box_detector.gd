class_name EntityHitBoxDetector extends Area3D

#region Public References
@onready var collision_object := %CollisionObject as CollisionShape3D
#endregion

#region Private Variables
var _entity: Entity
var _hit_box: EntityHitBox
var _collision_shape: BoxShape3D
#endregion

#region Public Methods
func update() -> void:
	if collision_object.shape != null and collision_object.shape is BoxShape3D:
		_collision_shape = collision_object.shape as BoxShape3D
	
	if _collision_shape == null:
		_collision_shape = BoxShape3D.new()
		_collision_shape.size.z = MainConstants.COLLISION_THICKNESS
		collision_object.shape = _collision_shape
	
	_collision_shape.size.x = _hit_box.data.size
	_collision_shape.size.y = _hit_box.data.size
	collision_object.disabled = _hit_box.data.is_disabled()


func get_entity() -> Entity:
	return _entity


func get_hit_box() -> EntityHitBox:
	return _hit_box
#endregion
