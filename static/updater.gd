class_name Updater

#region Constants
const DEFAULT_UPDATE_STEP_PREFIX: String = "_update_step_"
const DEFAULT_ERROR_MESSAGE: String = "Update failed!"
#endregion

#region Signals
signal updated(state: bool)
#endregion

#region Private Methods
var _is_valid: bool
var _is_updating: bool

var _origin: Node

var _update_steps: Array[Callable]
var _update_steps_size: int
var _update_idx: int

var _print_info_enabled: bool
var _print_warnings_enabled: bool
#endregion

#region Public Methods
func start() -> void:
	if not _is_valid:
		push_error("This updater was not properly initialized!")
		return
	
	if _is_updating:
		if _print_warnings_enabled:
			push_warning("Update busy :: %s" % _origin)
		
		return
	
	_is_updating = true
	_update_idx = -1
	
	if _print_info_enabled:
		print("Update started :: %s" % _origin)
	
	enable_process(false)
	proceed()


func abort(error_message: String = DEFAULT_ERROR_MESSAGE) -> void:
	if not _is_updating:
		if _print_warnings_enabled:
			push_warning("Nothing to abort. This updater was not started yet :: %s" % _origin)
		
		return
	
	if not error_message.is_empty():
		push_error(error_message)
	
	_is_updating = false
	updated.emit(false)


func proceed(message: String = "") -> void:
	_update_idx += 1
	
	if _update_idx == _update_steps_size:
		if _print_info_enabled:
			print("Update finished :: %s" % _origin)
		
		enable_process(true)
		
		_is_updating = false
		updated.emit(true)
		
		return
	
	var update_step: Callable = _update_steps[_update_idx]
	
	if _print_info_enabled:
		print("\t%s%s :: %d / %d" % [
			update_step.get_method().trim_prefix(DEFAULT_UPDATE_STEP_PREFIX).capitalize(),
			("" if message.is_empty() else (" > %s" % message)),
			_update_idx + 1,
			_update_steps_size
			])
	
	update_step.call()


func proceed_or_abort(state: bool, error_message: String = DEFAULT_ERROR_MESSAGE) -> void:
	if state:
		proceed()
	
	else:
		abort(error_message)


func enable_process(state: bool) -> void:
	_origin.set_process(state)
	_origin.set_physics_process(state)
	_origin.set_process_input(state)
	_origin.set_process_unhandled_input(state)


func is_updating() -> bool:
	return _is_updating
#endregion

#region Private Methods
func _init(
	origin: Node,
	update_steps: Array[Callable],
	print_info_enabled: bool = false,
	print_warnings_enabled: bool = true,
	) -> void:
		if origin == null:
			push_error("Origin reference not provided!")
			return
		
		if update_steps.is_empty():
			push_error("Update steps not provided!")
			return
		
		_origin = origin
		
		_update_steps = update_steps
		_update_steps_size = update_steps.size()
		
		_print_info_enabled = print_info_enabled
		_print_warnings_enabled = print_warnings_enabled
		
		_is_valid = true
		enable_process(false)
#endregion
