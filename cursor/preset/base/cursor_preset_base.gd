class_name CursorPresetBase extends Node3D

#region Constants
const POSITION_FRONT: float = 0.0
const POSITION_BACK: float = -2.0

#region Exports
@export var data: CursorPresetBaseData
#endregion

#region Public References
@onready var updater: Updater = Updater.new(self, [
	_update_step_base_check,
	_update_step_cursor,
	_update_step_sprites,
	_update_step_detectors,
	])

@onready var sprites_container := %SpritesContainer as Node3D
@onready var detectors_container := %DetectorsContainer as Node3D
@onready var entity_detector := %EntityDetector as CursorEntityDetector

@onready var viewport := get_viewport() as Viewport
@onready var camera := viewport.get_camera_3d() as Camera3D
#endregion

#region Private Variables
var _cursor: Cursor

var _sprites: Array[Sprite3D]
var _hit_box_detectors: Array[CursorHitBoxDetector]

var _move_velocity: Vector3
var _move_target_position: Vector3
var _move_is_mouse_controlling: bool

var _rotation_velocity: float
#endregion

#region Public Methods
static func instantiate(cursor: Cursor, pack_uid: String) -> CursorPresetBase:
	if cursor == null:
		push_error("The provided Cursor reference is null!")
		return null
	
	if pack_uid.is_empty():
		push_error("Missing pack UID!")
		return null
	
	var packed_scene := load(pack_uid) as PackedScene
	
	if not packed_scene.can_instantiate():
		push_error("CursorPresetBase scene cannot be instantiated!")
		return null
	
	var instance: Node = packed_scene.instantiate()
	
	if instance == null:
		push_error("CursorPresetBase scene instance returned null!")
		return null
	
	if not instance is CursorPresetBase:
		push_error("This instance is not a valid CursorPresetBase reference!")
		return null
	
	var preset_instance := instance as CursorPresetBase
	
	preset_instance._cursor = cursor
	
	return preset_instance
#endregion

#region Update Methods
func _update_step_base_check() -> void:
	if not is_inside_tree():
		updater.abort("This CursorPresetBase is not inside the SceneTree!")
		return
	
	if data == null:
		data = CursorPresetBaseData.new()
	
	updater.proceed()


func _update_step_cursor() -> void:
	_cursor.position.z = POSITION_FRONT if data.target_mode_is_front() else POSITION_BACK
	updater.proceed()


func _update_step_sprites() -> void:
	_sprites.clear()
	
	for child: Node in sprites_container.get_children():
		if child is Sprite3D:
			var sprite := child as Sprite3D
			
			_sprites.append(sprite)
			
			sprite.double_sided = false
			sprite.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			sprite.render_priority = MainConstants.RENDER_PRIORITY_CURSOR
	
	updater.proceed()


func _update_step_detectors() -> void:
	_hit_box_detectors.clear()
	
	for child: Node in detectors_container.get_children():
		if child is CursorHitBoxDetector:
			var detector := child as CursorHitBoxDetector
			
			if not detector.update(_cursor):
				updater.abort()
				return
			
			_hit_box_detectors.append(detector)
		
		elif child is CursorEntityDetector:
			var detector := child as CursorEntityDetector
			
			if not detector.update(_cursor):
				updater.abort()
				return
	
	updater.proceed()
#endregion

#region Input Methods
func _input(event: InputEvent) -> void:
	_input_movement(event)
	_input_rotation(event)


func _input_movement(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var mouse_motion_event := event as InputEventMouseMotion
		var camera_projected_position: Vector3 = camera.project_position(
			mouse_motion_event.position, absf(camera.global_position.z - global_position.z)
			)
		
		_move_target_position = Vector3(
			camera_projected_position.x, camera_projected_position.y, global_position.z
			)
		_move_is_mouse_controlling = true
		_move_velocity = Vector3.ZERO


func _input_rotation(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_button_event := event as InputEventMouseButton
		
		if data.rotation_mode == CursorPresetBaseData.RotationMode.FREEFORM:
			if mouse_button_event.is_pressed():
				if mouse_button_event.button_index == MOUSE_BUTTON_WHEEL_UP:
					_rotation_velocity = -data.rotation_speed
				
				elif mouse_button_event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
					_rotation_velocity = data.rotation_speed
#endregion

#region Process Methods
func _physics_process(delta: float) -> void:
	_process_movement(delta)
	_process_rotation(delta)


func _process_movement(delta: float) -> void:
	var action_input: Vector2 = Input.get_vector(
		MainConstants.ACTION_CURSOR_MOVE_LEFT,
		MainConstants.ACTION_CURSOR_MOVE_RIGHT,
		MainConstants.ACTION_CURSOR_MOVE_UP,
		MainConstants.ACTION_CURSOR_MOVE_DOWN,
		)
	var has_action_input: bool = action_input.length_squared() > 0.0
	
	if has_action_input:
		_move_is_mouse_controlling = false
	
	if _move_is_mouse_controlling:
		_cursor.global_position = _cursor.global_position.lerp(
			_move_target_position, data.move_speed * delta
			)
	
	else:
		var velocity: Vector3 = Vector3(
			action_input.x, -action_input.y, 0.0
			) * data.move_speed
		var weight: float = (
			data.move_acceleration if has_action_input else data.move_friction
			) * delta
		
		_move_velocity = _move_velocity.lerp(velocity, weight)
		_cursor.global_position += _move_velocity * delta
		_move_target_position = _cursor.global_position


func _process_rotation(delta: float) -> void:
	match data.rotation_mode:
		CursorPresetBaseData.RotationMode.FREEFORM:
			var action_input: float = Input.get_axis(
				MainConstants.ACTION_CURSOR_ROTATE_LEFT,
				MainConstants.ACTION_CURSOR_ROTATE_RIGHT
				)
			var has_action_input: bool = not is_zero_approx(action_input)
			var weight: float = (
				data.rotation_acceleration if has_action_input else data.rotation_friction
				) * delta
			
			_rotation_velocity = lerpf(
				_rotation_velocity, action_input * data.rotation_speed, weight
				)
			_cursor.rotate_object_local(Vector3.FORWARD, _rotation_velocity * delta)
		
		CursorPresetBaseData.RotationMode.SPRITE_CENTER_FOCUSED:
			var target_basis: Basis
			
			if Hub.cursor_detected_entity == null:
				target_basis = Basis.IDENTITY
			
			else:
				var direction: Vector3 = (
					Hub.cursor_detected_entity.global_position - global_position
					)
				
				target_basis = Basis(Vector3.BACK, atan2(direction.y, direction.x))
			
			_cursor.global_transform.basis = global_transform.basis.slerp(
				target_basis, data.rotation_speed * delta
				)
#endregion

#region Private Methods
func _ready() -> void:
	_move_target_position = global_position
#endregion
