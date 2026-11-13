class_name EntityPresetBase extends Node

#region Constants
const CURSOR_TRACKING_MAX_SIZE: float = 16.0 / MainConstants.PIXELS_PER_METER
#endregion

#region Exports
@export var data: EntityPresetBaseData
#endregion

#region Public References
@onready var sprites_container := %SpritesContainer as Node2D
@onready var hit_boxes_layer := %HitBoxesLayer as TileMapLayer
@onready var cursor_detection := %CursorDetection as CollisionShape2D
#endregion

#region Private Variables
var _entity: Entity
var _cursor_detection_shape: CircleShape2D
#endregion

#region Public Methods
static func instantiate(entity: Entity, pack_uid: String) -> EntityPresetBase:
	if entity == null:
		push_error("The provided Entity reference is null!")
		return null
	
	if pack_uid.is_empty():
		push_error("Missing pack UID!")
		return null
	
	var packed_scene := load(pack_uid) as PackedScene
	
	if not packed_scene.can_instantiate():
		push_error("EntityPresetBase scene cannot be instantiated!")
		return null
	
	var instance: Node = packed_scene.instantiate()
	
	if instance == null:
		push_error("EntityPresetBase scene instance returned null!")
		return null
	
	if not instance is EntityPresetBase:
		push_error("This instance is not a valid EntityPresetBase reference!")
		return null
	
	var preset_instance := instance as EntityPresetBase
	
	if preset_instance.data == null:
		push_error("No EntityPresetBaseData reference was provided!")
		return null
	
	if preset_instance.data.hit_boxes_subdivision_size_bounds <= Vector2i.ZERO:
		push_error("The subdivision size bounds coordinates cannot be 0 or less!")
		return null
	
	preset_instance._entity = entity
	
	return preset_instance


func get_3d_sprites() -> Array[Sprite3D]:
	var sprites_3d: Array[Sprite3D]
	
	for child: Node in sprites_container.get_children():
		if child is Sprite2D:
			var sprite_3d: Sprite3D = _convert_sprite_2d_to_3d(child as Sprite2D)
			
			if sprite_3d != null:
				sprites_3d.append(sprite_3d)
	
	return sprites_3d


func get_hit_boxes() -> Array[EntityHitBox]:
	var coords: Dictionary[Vector2, float] = Utils.get_subdivided_tile_coord_positions(
		hit_boxes_layer.get_used_cells(),
		MainConstants.TILE_SIZE_M,
		data.hit_boxes_subdivision_count_ratio,
		data.hit_boxes_subdivision_size_bounds,
		)
	
	if coords.is_empty():
		push_error("Could not subdivide the used tile cell coordinates!")
		return []
	
	var hit_boxes: Array[EntityHitBox]
	
	for position: Vector2 in coords:
		var hit_box_data: EntityHitBoxData = EntityHitBoxData.new()
		var size: float = coords[position]
		var size_half: float = size / 2.0
		
		hit_box_data.size = size
		hit_box_data.position = Vector3(position.x + size_half, -position.y - size_half, 0.0)
		hit_box_data.cursor_tracking_enabled = size >= CURSOR_TRACKING_MAX_SIZE
		
		hit_boxes.append(EntityHitBox.instantiate(_entity, hit_box_data))
	
	return hit_boxes


func get_cursor_detector() -> EntityCursorDetector:
	if cursor_detection.shape == null or not cursor_detection.shape is CircleShape2D:
		push_error("The cursor detection shape is either null or not a valid CircleShape2D!")
		return null
	
	_cursor_detection_shape = cursor_detection.shape as CircleShape2D
	
	return EntityCursorDetector.instantiate(_entity, _cursor_detection_shape.radius)
#endregion

#region Pivate Methods
func _convert_sprite_2d_to_3d(sprite_2d: Sprite2D) -> Sprite3D:
	if not Utils.check_node(sprite_2d, "Sprite2D"):
		return
	
	var sprite_2d_position: Vector2 = sprite_2d.position / MainConstants.PIXELS_PER_METER
	var sprite_3d: Sprite3D = Sprite3D.new()
	
	sprite_3d.texture = sprite_2d.texture
	sprite_3d.modulate = sprite_2d.modulate
	
	sprite_3d.position = Vector3(sprite_2d_position.x, -sprite_2d_position.y, 0.0)
	sprite_3d.scale = Vector3(sprite_2d.scale.x, sprite_2d.scale.y, 1.0)
	sprite_3d.rotation.z = -sprite_2d.rotation
	
	sprite_3d.double_sided = false
	sprite_3d.render_priority = Utils.get_clamped_render_priority(sprite_2d.get_index())
	
	return sprite_3d
#endregion
