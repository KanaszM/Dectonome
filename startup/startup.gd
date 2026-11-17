class_name Startup extends Node

#region Private Methods
func _ready() -> void:
	var game_data: SessionGameData = SessionGameData.new()
	
	Session.new_game_set.connect(_on_session_new_game_set, CONNECT_ONE_SHOT)
	Session.set_new_game(game_data)


var test_level: MapSegmentData.Level = MapSegmentData.Level.GROUND
func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		var key_event := event as InputEventKey
		
		if key_event.is_pressed():
			match key_event.keycode:
				Key.KEY_Q:
					test_level = MapSegmentData.iterate_level(test_level, false, 6)
					print(test_level)
				
				Key.KEY_E:
					test_level = MapSegmentData.iterate_level(test_level, true, 6)
					print(test_level)


func _on_session_new_game_set(state: bool) -> void:
	if state:
		print("SUCCESS!")
		
		
		var test: MapSegmentDataTest1 = MapSegmentDataTest1.new()
		
		test.type = MapSegmentData.Type.STRAIGHT
		test.biome = MapSegmentDataTest1.Biome.LIGHT_RED
		print(test.get_pack_path())
#endregion
