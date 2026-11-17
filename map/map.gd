extends Node3D

#region Signals
signal removed
#endregion

#region Public References
@onready var world_environment := %WorldEnvironment as WorldEnvironment
@onready var environment: Environment = world_environment.environment

@onready var player_container := %PlayerContainer as Node3D
@onready var segments_container := %SegmentsContainer as Node3D
#endregion

#region Public Methods
func remove() -> void:
	removed.emit()
#endregion
