extends Node

#region Public References
var startup: Startup
#endregion

#region Private Methods
func _ready() -> void:
	startup = get_tree().current_scene as Startup
#endregion
