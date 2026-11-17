extends Node

#region Signals
signal setting_new_name
signal new_game_set(state: bool)
#endregion

#region Public References
@onready var updater_new_game: Updater = Updater.new(self, [
	_update_step_new_game_base_check,
	_update_step_new_game_remove_current_player,
	_update_step_new_game_remove_current_map,
	], true, true)
#endregion

#region Private Variables
var _game_data: SessionGameData
#endregion

#region Public Methods
func set_new_game(game_data: SessionGameData) -> void:
	var func_on_finished: Callable = func(state: bool, error_message: String = "") -> void:
		if not state and not error_message.is_empty():
			push_error(error_message)
		
		new_game_set.emit(state)
	
	setting_new_name.emit()
	
	if updater_new_game.is_updating():
		func_on_finished.call(false, "The previous request has not been finished yet!")
		return
	
	_game_data = game_data
	updater_new_game.updated.connect(func_on_finished, CONNECT_ONE_SHOT)
	updater_new_game.start()
#endregion

#region Private Methods (New Game Updater)
func _update_step_new_game_base_check() -> void:
	if _game_data == null:
		updater_new_game.abort("The provided SessionGameData reference is null!")
		return
	
	updater_new_game.proceed("Creating a new game: %s" % _game_data.get_name_with_id())


func _update_step_new_game_remove_current_player() -> void:
	var func_on_player_removed: Callable = func() -> void:
		updater_new_game.proceed()
	
	Player.removed.connect(func_on_player_removed, CONNECT_ONE_SHOT)
	Player.remove()


func _update_step_new_game_remove_current_map() -> void:
	var func_on_map_removed: Callable = func() -> void:
		updater_new_game.proceed()
	
	Map.removed.connect(func_on_map_removed, CONNECT_ONE_SHOT)
	Map.remove()
#endregion
