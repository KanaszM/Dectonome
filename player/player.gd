extends Node

#region Signals
signal removed
#endregion

#region Public Methods
func remove() -> void:
	removed.emit()
#endregion
