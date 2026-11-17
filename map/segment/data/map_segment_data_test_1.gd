class_name MapSegmentDataTest1 extends MapSegmentData

#region Enums
enum Biome {
	LIGHT_RED,
	MEDIUM_VIOLET_RED,
	DARK_RED,
	}
#endregion

#region Exports
@export var biome: Biome
#endregion

#region Public Methods
func biome_to_str(replace_spaces: bool = true) -> String:
	return Utils.enum_to_str(Biome, biome, true, replace_spaces)
#endregion

#region Private Methods
func _init() -> void:
	super._init(Level.TEST_1)
#endregion
