class_name Startup extends Node

#region Private Methods
func _ready() -> void:
	var game_data: SessionGameData = SessionGameData.new()
	
	Session.game_set.connect(_on_session_game_set, CONNECT_ONE_SHOT)
	Session.set_new_game(game_data)


func _on_session_game_set(state: bool) -> void:
	if state:
		print("SUCCESS!")
#endregion
