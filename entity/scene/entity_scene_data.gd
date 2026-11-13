class_name EntitySceneData extends Resource

#region Exports
@export_group("Cursor", "cursor_")
@export_file("*.tscn") var cursor_preset_file: String

@export_group("Entities", "entity_")
@export_subgroup("Front Row", "entity_front_")
@export_file("*.tscn") var entity_front_left: String
@export_file("*.tscn") var entity_front_middle: String
@export_file("*.tscn") var entity_front_right: String

@export_subgroup("Back Row", "entity_back_")
@export_file("*.tscn") var entity_back_left: String
@export_file("*.tscn") var entity_back_middle: String
@export_file("*.tscn") var entity_back_right: String
#endregion

#region Public Methods
func get_entity_preset_files() -> Dictionary[EntityScene.Position, String]:
	return {
		EntityScene.Position.FRONT_LEFT: entity_front_left,
		EntityScene.Position.FRONT_MIDDLE: entity_front_middle,
		EntityScene.Position.FRONT_RIGHT: entity_front_right,
		EntityScene.Position.BACK_LEFT: entity_back_left,
		EntityScene.Position.BACK_MIDDLE: entity_back_middle,
		EntityScene.Position.BACK_RIGHT: entity_back_right,
		} as Dictionary[EntityScene.Position, String]
#endregion
