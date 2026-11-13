class_name Utils

#region Private Variables
static var _counters: Dictionary[String, _Counter]
#endregion

#region Public Methods
static func check_callback(callback: Callable, name: String = "") -> bool:
	if callback.is_null() or not callback.is_valid():
		push_error(
			"The provided %sCallable is invalid!"
			% ("" if name.is_empty() else ("[%s] " % name))
			)
		return false
	
	return true


static func check_node(node: Node, name: String = "") -> bool:
	if node == null:
		push_error(
			"The provided %sNode reference is invalid!"
			% ("" if name.is_empty() else ("[%s] " % name))
			)
		return false
	
	return true


static func remove_node_and_execute(node: Node, callback: Callable) -> void:
	if not check_node(node) or not check_callback(callback):
		return
	
	node.tree_exited.connect(callback, CONNECT_ONE_SHOT)
	node.queue_free()


static func remove_nodes_and_execute(from: Node, callback: Callable) -> void:
	if not check_node(from) or not check_callback(callback):
		return
	
	var counter_key: String = "%d%d" % [from.get_instance_id(), randi()]
	var func_execute_callback: Callable = func() -> void:
		if counter_key in _counters:
			_counters.erase(counter_key)
		
		callback.call()
	
	var child_count: int = from.get_child_count()
	
	if child_count == 0:
		func_execute_callback.call()
		return
	
	var counter: _Counter = _Counter.new(child_count)
	var func_on_child_tree_exited: Callable = func() -> void:
		counter.increment()
		
		if counter.current_is_equal():
			func_execute_callback.call()
	
	_counters[counter_key] = counter
	
	for child: Node in from.get_children():
		child.tree_exited.connect(func_on_child_tree_exited, CONNECT_ONE_SHOT)
		child.queue_free()


static func add_node_and_execute(parent: Node, child: Node, callback: Callable) -> void:
	if (
		not check_node(parent, "Parent")
		or not check_node(child, "Child")
		or not check_callback(callback)
		):
			return
	
	child.ready.connect(callback, CONNECT_ONE_SHOT)
	parent.add_child(child)


static func add_nodes_and_execute(parent: Node, children: Array[Node], callback: Callable) -> void:
	if (
		not check_node(parent, "Parent")
		or not check_callback(callback)
		):
			return
	
	if children.is_empty():
		push_warning("No children nodes were provided.")
		return
	
	var counter_key: String = "%d%d" % [parent.get_instance_id(), randi()]
	var counter: _Counter = _Counter.new(children.size())
	var func_on_child_ready: Callable = func() -> void:
		counter.increment()
		
		if counter.current_is_equal():
			_counters.erase(counter_key)
			callback.call()
	
	_counters[counter_key] = counter
	
	for child: Node in children:
		child.ready.connect(func_on_child_ready, CONNECT_ONE_SHOT)
		parent.add_child(child)


static func get_subdivided_tile_coord_positions(
	tile_coords: Array[Vector2i],
	tile_size: float,
	subdivision_count_ratio: float,
	subdivision_size_bounds: Vector2i,
	) -> Dictionary[Vector2, float]:
		if tile_coords.is_empty():
			return {}
		
		var results: Dictionary[Vector2, float] = {}
		var subdivision_size_bounds_min: int = mini(
			subdivision_size_bounds.x, subdivision_size_bounds.y
			)
		var subdivision_size_bounds_max: int = maxi(
			subdivision_size_bounds.x, subdivision_size_bounds.y
			)
		
		subdivision_count_ratio = clampf(subdivision_count_ratio, 0.0, 1.0)
		
		for coord: Vector2i in tile_coords:
			var position: Vector2 = Vector2(coord) * tile_size
			
			if randf() < subdivision_count_ratio:
				var split: int = randi_range(
					subdivision_size_bounds_min, subdivision_size_bounds_max
					)
				var size: float = tile_size / float(split)
				
				for x: int in split:
					for y: int in split:
						results[position + Vector2(x * size, y * size)] = size
			
			else:
				results[position] = tile_size
		
		return results


static func get_plane_intersection(plane: Plane, from: Vector3, direction: Vector3) -> Vector3:
	var plane_intersection := plane.intersects_ray(from, direction) as Vector3
	
	return Vector3.INF if plane_intersection == null else plane_intersection as Vector3


static func get_clamped_render_priority(value: int) -> int:
	return clampi(
		value, MainConstants.RENDER_PRIORITY_BOUNDS.x, MainConstants.RENDER_PRIORITY_BOUNDS.y
		)
#endregion

#region Private SubClasses
class _Counter extends RefCounted:
	#region Public Variables
	var value_max: int
	var value_current: int
	#endregion
	
	#region Public Methods
	func increment() -> void:
		value_current += 1
	
	
	func current_is_equal() -> bool:
		return value_current == value_max
	
	
	func current_is_greater_or_equal() -> bool:
		return value_current >= value_max
	#endregion
	
	#region Private Methods
	func _init(value_max_arg: int = 0, value_current_arg: int = 0) -> void:
		value_max = value_max_arg
		value_current = value_current_arg
	#endregion
#endregion
