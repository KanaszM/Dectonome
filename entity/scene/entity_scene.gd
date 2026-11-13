class_name EntityScene extends Node3D

#region Constants
const PACK_UID: String = "uid://4by74shslpib"
const ENTITY_UPSERT_COUNT_MAX: int = 6
#endregion

#region Enums
enum Position {
	FRONT_LEFT,
	FRONT_MIDDLE,
	FRONT_RIGHT,
	BACK_LEFT,
	BACK_MIDDLE,
	BACK_RIGHT,
	}
#endregion

#region Exports
@export var data: EntitySceneData
#endregion

#region Public References
@onready var updater: Updater = Updater.new(self, [
	_update_step_base_check,
	_update_step_cursor,
	_update_step_entities,
	_update_step_hit_boxes_visibility,
	])

@onready var ui_focused := %UIFocused as EntitySceneUIFocused
@onready var cursor_container := %CursorContainer as Node3D

@onready var entity_container_rows := %EntityContainerRows as Node3D
@onready var entity_container_row_front := %EntityContainerRowFront as Node3D
@onready var entity_container_front_left := %EntityContainerFrontLeft as Marker3D
@onready var entity_container_front_middle := %EntityContainerFrontMiddle as Marker3D
@onready var entity_container_front_right := %EntityContainerFrontRight as Marker3D

@onready var entity_container_row_back := %EntityContainerRowBack as Node3D
@onready var entity_container_back_left := %EntityContainerBackLeft as Marker3D
@onready var entity_container_back_middle := %EntityContainerBackMiddle as Marker3D
@onready var entity_container_back_right := %EntityContainerBackRight as Marker3D
#endregion

#region Private Variables
var _local_cursor_instance: Cursor

var _entities: Dictionary[Position, Entity] = {
	Position.FRONT_LEFT: null,
	Position.FRONT_MIDDLE: null,
	Position.FRONT_RIGHT: null,
	Position.BACK_LEFT: null,
	Position.BACK_MIDDLE: null,
	Position.BACK_RIGHT: null,
	}

@onready var _entity_containers: Dictionary[Position, Marker3D] = {
	Position.FRONT_LEFT: entity_container_front_left,
	Position.FRONT_MIDDLE: entity_container_front_middle,
	Position.FRONT_RIGHT: entity_container_front_right,
	Position.BACK_LEFT: entity_container_back_left,
	Position.BACK_MIDDLE: entity_container_back_middle,
	Position.BACK_RIGHT: entity_container_back_right,
	}

var _entity_upsert_count_current: int
#endregion

#region Public Methods
static func instantiate(arg_data: EntitySceneData = null) -> EntityScene:
	var packed_scene := load(PACK_UID) as PackedScene
	
	if not packed_scene.can_instantiate():
		push_error("EntityScene scene cannot be instantiated!")
		return null
	
	var instance := packed_scene.instantiate() as EntityScene
	
	if instance == null:
		push_error("EntityScene scene instance returned null!")
		return null
	
	instance.data = arg_data
	
	return instance


static func position_is_front(entity_position: Position) -> bool:
	match entity_position:
		Position.FRONT_LEFT, Position.FRONT_MIDDLE, Position.FRONT_RIGHT: return true
		_: return false
#endregion

#region Update Methods
func _update_step_base_check() -> void:
	if not is_inside_tree():
		updater.abort("This EntityScene is not inside the SceneTree!")
		return
	
	if data == null:
		data = EntitySceneData.new()
	
	updater.proceed()


func _update_step_cursor() -> void:
	var func_on_cursor_instance_updated: Callable = func(state: bool) -> void:
		if state:
			Hub.set_cursor(_local_cursor_instance)
			updater.proceed()
		
		else:
			Hub.set_cursor(null)
			updater.abort()
		
	var func_update_cursor_instance: Callable = func() -> void:
		_local_cursor_instance.updater.updated.connect(
			func_on_cursor_instance_updated, CONNECT_ONE_SHOT
			)
		_local_cursor_instance.updater.start()
	
	for child: Node in cursor_container.get_children():
		if child is Cursor:
			_local_cursor_instance = child as Cursor
			break
	
	if _local_cursor_instance == null:
		if data.cursor_preset_file.is_empty():
			func_on_cursor_instance_updated.call(false)
			return
		
		_local_cursor_instance = Cursor.instantiate(data.cursor_preset_file)
		
		if _local_cursor_instance == null:
			func_on_cursor_instance_updated.call(false)
			return
		
		_local_cursor_instance.ready.connect(func_update_cursor_instance, CONNECT_ONE_SHOT)
		cursor_container.add_child(_local_cursor_instance)
	
	else:
		func_update_cursor_instance.call()


func _update_step_entities() -> void:
	var entity_preset_files: Dictionary[Position, String] = data.get_entity_preset_files() 
	var func_increment_entity_upsert_counter: Callable = func(state: bool = true) -> void:
		if not state:
			updater.abort()
			return
		
		_entity_upsert_count_current += 1
		
		if _entity_upsert_count_current == ENTITY_UPSERT_COUNT_MAX:
			updater.proceed()
	
	_entity_upsert_count_current = 0
	
	for entity_position: Position in entity_preset_files:
		var preset_file: String = entity_preset_files[entity_position]
		var container: Node3D = _entity_containers[entity_position]
		var local_entity_instance: Entity
		
		for child: Node in container.get_children():
			if child is Entity:
				local_entity_instance = child as Entity
				_entities[entity_position] = local_entity_instance
				break
		
		if local_entity_instance == null:
			if preset_file.is_empty():
				func_increment_entity_upsert_counter.call()
				continue
			
			local_entity_instance = Entity.instantiate(preset_file)
			
			if local_entity_instance == null:
				updater.abort()
				continue
			
			var func_on_local_entity_ready: Callable = func() -> void:
				_entities[entity_position] = local_entity_instance
				local_entity_instance.updater.updated.connect(
					func_increment_entity_upsert_counter, CONNECT_ONE_SHOT
					)
				local_entity_instance.updater.start()
			
			local_entity_instance.ready.connect(func_on_local_entity_ready, CONNECT_ONE_SHOT)
			container.add_child(local_entity_instance)
		
		else:
			local_entity_instance.updater.updated.connect(
				func_increment_entity_upsert_counter, CONNECT_ONE_SHOT
				)
			local_entity_instance.updater.start()


func _update_step_hit_boxes_visibility() -> void:
	if Hub.cursor == null:
		updater.proceed()
		return
	
	var cursor_target_mode_is_front: bool = Hub.cursor.get_preset_data().target_mode_is_front()
	
	for entity_position: Position in _entities:
		var entity: Entity = _entities[entity_position]
		
		if entity == null:
			continue
		
		var entity_position_is_front: bool = position_is_front(entity_position)
		var entity_hit_boxes_are_visible: bool = (
			(entity_position_is_front and cursor_target_mode_is_front)
			or (not entity_position_is_front and not cursor_target_mode_is_front)
			)
		
		entity.hit_boxes_container.visible = entity_hit_boxes_are_visible
	
	updater.proceed()
#endregion
