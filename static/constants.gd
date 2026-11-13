class_name MainConstants

#region Constants
const PIXELS_PER_METER: float = 100.0

const TILE_SIZE: float = 32.0
const TILE_SIZE_M: float = TILE_SIZE * 0.01

const COLLISION_THICKNESS: float = 0.01

const RENDER_PRIORITY_BOUNDS: Vector2i = Vector2i(-128, 127)
const RENDER_PRIORITY_CURSOR: int = 126
const RENDER_PRIORITY_HIT_BOX: int = 100
const RENDER_PRIORITY_HIT_BOX_FOCUS: int = 101
const RENDER_PRIORITY_HIT_BOX_LABEL: int = 101
const RENDER_PRIORITY_HIT_BOX_LABEL_OUTLINE: int = 102

const COLLISION_LAYER_HIT_BOX: int = 1
const COLLISION_LAYER_CURSOR: int = 2
const COLLISION_LAYER_ENTITY_CURSOR_DETECTOR: int = 3

const ACTION_CURSOR_MOVE_LEFT: StringName = &"cursor_move_left"
const ACTION_CURSOR_MOVE_RIGHT: StringName = &"cursor_move_right"
const ACTION_CURSOR_MOVE_UP: StringName = &"cursor_move_up"
const ACTION_CURSOR_MOVE_DOWN: StringName = &"cursor_move_down"
const ACTION_CURSOR_ROTATE_LEFT: StringName = &"cursor_rotate_left"
const ACTION_CURSOR_ROTATE_RIGHT: StringName = &"cursor_rotate_right"
const ACTION_CURSOR_ACTIVATE: StringName = &"cursor_activate"
#endregion
