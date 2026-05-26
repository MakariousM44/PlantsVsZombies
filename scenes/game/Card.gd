class_name Card
extends PanelContainer

signal card_selected(unit_data: UnitData)

@export var unit_data: UnitData

@onready var icon: TextureRect = $VBoxContainer/Icon
@onready var name_label: Label = $VBoxContainer/NameLabel
@onready var cost_label: Label = $VBoxContainer/CostLabel

func _ready() -> void:
	if unit_data:
		setup(unit_data)

func setup(data: UnitData) -> void:
	unit_data = data
	icon.texture = data.icon
	name_label.text = data.unit_name
	cost_label.text = str(data.cost)

func _on_gui_input(event: InputEvent) -> void:
	if unit_data == null:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			card_selected.emit(unit_data)
