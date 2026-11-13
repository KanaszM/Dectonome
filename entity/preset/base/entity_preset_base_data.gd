class_name EntityPresetBaseData extends Resource

#region Exports
@export_group("Identity", "id_")
@export var id_name: String

@export_group("HitBoxes", "hit_boxes_")
@export_subgroup("Subdivision", "hit_boxes_subdivision_")
@export_range(0.0, 1.0, 0.001) var hit_boxes_subdivision_count_ratio: float
@export var hit_boxes_subdivision_size_bounds: Vector2i = Vector2i.ONE

@export_subgroup("Values", "hit_boxes_values_")
@export var hit_boxes_values_bounds: Vector2i
#endregion

#region Public Methods
func get_random_hit_box_value() -> int:
	return randi_range(
		mini(hit_boxes_values_bounds.x, hit_boxes_values_bounds.y),
		maxi(hit_boxes_values_bounds.x, hit_boxes_values_bounds.y),
		)
#endregion
