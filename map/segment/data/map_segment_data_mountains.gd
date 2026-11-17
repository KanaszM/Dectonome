class_name MapSegmentDataMountains extends MapSegmentData

#region Enums
enum Biome {
	PEAKS,
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
	super._init(Level.MOUNTAINS)
#endregion
