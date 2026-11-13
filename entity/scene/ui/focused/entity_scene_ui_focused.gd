class_name EntitySceneUIFocused extends Control

#region Public References
@onready var margin_background := %MarginBackground as MarginContainer

@onready var panel_focused_entity := %PanelFocusedEntity as PanelContainer
@onready var margin_focused_entity := %MarginFocusedEntity as MarginContainer
@onready var v_box_focused_entity := %VBoxFocusedEntity as VBoxContainer
@onready var label_focused_entity_name := %LabelFocusedEntityName as Label

@onready var v_box_focused_entity_health := %VBoxFocusedEntityHealth as HBoxContainer
@onready var label_focused_entity_health_current := %LabelFocusedEntityHealthCurrent as Label
@onready var label_focused_entity_health_max := %LabelFocusedEntityHealthMax as Label
@onready var bar_focused_entity_health := %BarFocusedEntityHealth as ProgressBar
#endregion

#region Private Variables
var _focused_entity: Entity
#endregion

#region Private Methods
func _ready() -> void:
	Hub.cursor_entity_detection_changed.connect(_on_MainHub_cursor_entity_detection_changed)
	
	_update_focused_entity_panel()


func _update_focused_entity_panel() -> void:
	panel_focused_entity.visible = false
	
	if _focused_entity == null:
		return
	
	var focused_entity_data: EntityPresetBaseData = _focused_entity.get_preset_data()
	var hit_box_values_max: int = _focused_entity.get_hit_box_values_max()
	var hit_box_values_current: int = _focused_entity.get_hit_box_values_current()
	
	panel_focused_entity.visible = true
	label_focused_entity_name.text = focused_entity_data.id_name
	
	bar_focused_entity_health.max_value = float(hit_box_values_max)
	bar_focused_entity_health.value = float(hit_box_values_current)
	label_focused_entity_health_max.text = str(hit_box_values_max)
	label_focused_entity_health_current.text = str(hit_box_values_current)


func _on_MainHub_cursor_entity_detection_changed() -> void:
	_focused_entity = Hub.cursor_detected_entity
	_update_focused_entity_panel()
#endregion
