class_name EntityHitBox extends Node3D

#region Constants
const PACK_UID: String = "uid://bf4v7u534la7k"
const GROUP: StringName = &"-EntityHitBox-"

const ROTATION_MAX_ANGLE: float = 0.15
const ROTATION_WEIGHT: float = 5.0

const MATERIAL_ALPHA: float = 0.75
#endregion

#region Exports
var data: EntityHitBoxData
#endregion

#region Public References
@onready var updater: Updater =  Updater.new(self, [
	_update_step_base_check,
	_update_step_pre_initialization,
	_update_step_mesh,
	_update_step_material,
	_update_step_detector,
	_update_step_label,
	])

@onready var mesh_instance := %MeshInstance as MeshInstance3D
@onready var label := %Label as Label3D
@onready var detector := %Detector as EntityHitBoxDetector
#endregion

#region Private Variables
var _is_focused: bool

var _entity: Entity
var _cursor: Cursor
var _mesh: QuadMesh
var _material: StandardMaterial3D
var _material_focused: StandardMaterial3D

var _update_step_pre_initialization_passed: bool
#endregion

#region Public Methods
static func instantiate(entity: Entity, hit_box_data: EntityHitBoxData) -> EntityHitBox:
	if entity == null:
		push_error("The provided Entity reference is null!")
		return null
	
	if hit_box_data == null:
		push_error("The provided EntityHitBoxData reference is null!")
		return null
	
	var packed_scene := load(PACK_UID) as PackedScene
	
	if not packed_scene.can_instantiate():
		push_error("EntityHitBox scene cannot be instantiated!")
		return null
	
	var instance := packed_scene.instantiate() as EntityHitBox
	
	if instance == null:
		push_error("EntityHitBox scene instance returned null!")
		return null
	
	instance._entity = entity
	instance.data = hit_box_data
	
	return instance


func set_cursor_tracking(cursor: Cursor) -> void:
	_cursor = cursor


func set_focused(state: bool) -> void:
	_is_focused = state
	_material.next_pass = _material_focused if state else null
#endregion

#region Update Methods
func _update_step_base_check() -> void:
	if not is_inside_tree():
		updater.abort("This HitBox is not inside the SceneTree!")
		return
	
	if data == null:
		updater.abort("EntityHitBoxData reference not provided!")
		return
	
	if data.size <= 0.0:
		updater.abort("Size cannot be 0.0 or less!")
		return
	
	updater.proceed()


func _update_step_pre_initialization() -> void:
	if _update_step_pre_initialization_passed:
		updater.proceed()
		return
	
	position = data.position
	data.value = _entity.get_preset_data().get_random_hit_box_value()
	
	label.render_priority = MainConstants.RENDER_PRIORITY_HIT_BOX_LABEL
	label.outline_render_priority = MainConstants.RENDER_PRIORITY_HIT_BOX_LABEL_OUTLINE
	
	_update_step_pre_initialization_passed = true
	updater.proceed()


func _update_step_mesh() -> void:
	if mesh_instance.mesh != null and mesh_instance.mesh is QuadMesh:
		_mesh = mesh_instance.mesh as QuadMesh
	
	if _mesh == null:
		_mesh = QuadMesh.new()
		mesh_instance.mesh = _mesh
	
	mesh_instance.visible = not data.is_disabled()
	_mesh.size = Vector2.ONE * data.size
	updater.proceed()


func _update_step_material() -> void:
	if _mesh.material != null and _mesh.material is StandardMaterial3D:
		_material = _mesh.material as StandardMaterial3D
	
	if _material == null:
		_material = Resources.MATERIAL_ENTITY_HIT_BOX_DEFAULT.duplicate() as StandardMaterial3D
		_mesh.material = _material
	
	if _material_focused == null:
		_material_focused = Resources.MATERIAL_ENTITY_HIT_BOX_FOCUSED
	
	updater.proceed()


func _update_step_detector() -> void:
	detector.update()
	updater.proceed()


func _update_step_label() -> void:
	label.text = str(data.value)
	label.font_size = int(data.size * MainConstants.PIXELS_PER_METER)
	label.outline_size = int(label.font_size / 4.0)
	updater.proceed()
#endregion

#region Process Methods
func _physics_process(delta: float) -> void:
	_process_cursor_tracking(delta)


func _process_cursor_tracking(delta: float) -> void:
	if not data.cursor_tracking_enabled:
		return
	
	var target: Basis
	
	if _cursor == null:
		target = Basis.IDENTITY
	
	elif mesh_instance.global_position.is_equal_approx(_cursor.global_position):
		return
	
	else:
		var local_target: Vector3 = to_local(_cursor.global_position)
		var local_basis: Basis = Basis.looking_at(local_target, Vector3.FORWARD)
		var euler: Vector3 = local_basis.get_euler()
		
		euler.x = -clampf(euler.x, -ROTATION_MAX_ANGLE, ROTATION_MAX_ANGLE)
		euler.y = -clampf(euler.y, -ROTATION_MAX_ANGLE, ROTATION_MAX_ANGLE)
		euler.z = 0.0
		target = Basis.from_euler(euler)
	
	mesh_instance.global_transform.basis = mesh_instance.global_transform.basis.slerp(
		target, ROTATION_WEIGHT * delta
		)
#endregion

#region Private Methods
func _ready() -> void:
	updater.enable_process(false)
	detector._entity = _entity
	detector._hit_box = self
	
	add_to_group(GROUP)
#endregion
