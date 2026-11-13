extends Node

#region Signals
signal game_set(state: bool)
signal game_removed
signal setting_new_name
#endregion

#region Private Variables
var _is_active: bool
var _is_setting_a_new_game: bool

var _game_data: SessionGameData
#endregion

#region Public Methods
func set_new_game(game_data: SessionGameData) -> void:
	var func_on_finished: Callable = func(error_message: String = "") -> void:
		if not error_message.is_empty():
			push_error(error_message)
			game_set.emit(false)
			return
		
		game_set.emit(true)
	
	if _is_active:
		func_on_finished.call("A session is already set!")
		return
	
	if game_data == null:
		func_on_finished.call("The provided SessionGameData reference is null!")
		return
	
	if _is_setting_a_new_game:
		func_on_finished.call("The previous request has not been finished yet!")
		return
	
	var func_process_new_game_set_request: Callable = func() -> void:
		_game_data = game_data
		
		func_on_finished.call()
	
	_is_active = false
	_is_setting_a_new_game = true
	setting_new_name.emit()
	
	if _game_data == null:
		func_process_new_game_set_request.call()
	
	else:
		var func_on_map_removed: Callable = func() -> void:
			game_removed.emit()
			func_process_new_game_set_request.call()
		
		Map.removed.connect(func_on_map_removed, CONNECT_ONE_SHOT)
		Map.remove()
#endregion
