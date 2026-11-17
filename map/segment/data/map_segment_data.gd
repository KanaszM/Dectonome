class_name MapSegmentData extends Resource

#region Enums
enum Level {
	ARCANE = -5,
	VOID = -4,
	ABYSS = -3,
	DUNGEON = -2,
	UNDERGROUND = -1,
	GROUND = 0,
	SETTLEMENT = 1,
	HILLS = 2,
	MOUNTAINS = 3,
	SKY = 4,
	SPACE = 5,
	
	TEST_1 = 100,
	TEST_2 = 200,
	TEST_3 = 300,
	}

enum Type {ENTRANCE, STRAIGHT, TYPE_CHANGE, LEVEL_CHANGE}
enum SubType {A, B, C}
#endregion

#region Constants
const REGULAR_LEVELS: Array[Level] = [
	Level.ARCANE,
	Level.VOID,
	Level.ABYSS,
	Level.DUNGEON,
	Level.UNDERGROUND,
	Level.GROUND,
	Level.SETTLEMENT,
	Level.HILLS,
	Level.MOUNTAINS,
	Level.SKY,
	Level.SPACE,
	]

const TEST_LEVELS: Array[Level] = [
	Level.TEST_1,
	Level.TEST_2,
	Level.TEST_3,
	]

const PACK_PATH_FORMAT: String = "res://map/segments/%s/%s/%s/%s.tscn"
#endregion

#region Exports
@export var type: Type
@export var sub_type: SubType
#endregion

#region Public Variables
var level: Level
#endregion

#region Public Methods
static func iterate_level(
	origin: Level, direction: bool, step: int = 1, wrap_around: bool = true
	) -> Level:
		var pool: Array[Level] = TEST_LEVELS if origin in TEST_LEVELS else REGULAR_LEVELS
		var current: int = pool.find(origin)
		
		if current == -1:
			return origin
		
		step = absi(step)
		
		var target: int = current + (step if direction else -step)
		var pool_size: int = pool.size()
		
		return pool[(
			wrapi(target, 0, pool_size) if wrap_around else clampi(target, 0, pool_size - 1)
			)]


static func get_levels() -> Array[Level]:
	return Array(Level.values(), TYPE_INT, &"", null) as Array[Level]


static func get_types() -> Array[Type]:
	return Array(Type.values(), TYPE_INT, &"", null) as Array[Type]


static func get_sub_types() -> Array[SubType]:
	return Array(SubType.values(), TYPE_INT, &"", null) as Array[SubType]


static func level_to_str(flag: Level, replace_spaces: bool = true) -> String:
	return Utils.enum_to_str(Level, flag, true, replace_spaces)


static func type_to_str(flag: Type, replace_spaces: bool = true) -> String:
	return Utils.enum_to_str(Type, flag, true, replace_spaces)


static func sub_type_to_str(flag: SubType, replace_spaces: bool = true) -> String:
	return Utils.enum_to_str(SubType, flag, true, replace_spaces)


func biome_to_str(_replace_spaces: bool = true) -> String:
	return ""


func get_pack_path() -> String:
	return PACK_PATH_FORMAT % [
		level_to_str(level, false),
		type_to_str(type, false),
		biome_to_str(false),
		sub_type_to_str(sub_type, false),
		]
#endregion

#region Private Methods
func _init(level_flag: Level) -> void:
	level = level_flag
#endregion
