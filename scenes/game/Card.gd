class_name Card
extends PanelContainer

signal card_selected(unit_data: UnitData)

@export var unit_data: UnitData

@onready var icon: TextureRect = $VBoxContainer/IconContainer/Icon
@onready var cost_label: Label = $VBoxContainer/IconContainer/CostLabel

func _ready() -> void:
	if unit_data:
		setup(unit_data)

func setup(data: UnitData) -> void:
	unit_data = data
	icon.texture = data.icon
	cost_label.text = str(data.cost)

func _on_gui_input(event: InputEvent) -> void:
	if unit_data == null:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			card_selected.emit(unit_data)
			accept_event()
