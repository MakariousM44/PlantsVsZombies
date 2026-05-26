extends Node

@onready var highlight = $"../Highlight"
@onready var selection_manager = $"../CanvasLayer/SelectionManager"

@onready var cursor_control: Control = $"../CanvasLayer/CursorControl"

var hovered_cell: Vector2i = Vector2i(-1, -1)

func _ready() -> void:
	selection_manager.unit_selected.connect(_on_selection_changed)

func _on_selection_changed(_unit_data: UnitData) -> void:
	_update_highlight(hovered_cell)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var cell = BoardStateManager.world_to_cell(get_viewport().get_mouse_position())
		_update_cursor(cell)
		if cell != hovered_cell:
			hovered_cell = cell
			_update_highlight(cell)

	var my_id = multiplayer.get_unique_id()
	if not NetworkManager.player_roles.has(my_id):
		return
	var role = NetworkManager.player_roles[my_id]

	if role == "plant":
		_handle_plant_input(event)
	else:
		_handle_zombie_input(event)

# ──────── plant functions ──────────

func _handle_plant_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var cell = BoardStateManager.world_to_cell(get_viewport().get_mouse_position())
			_on_plant_cell_clicked(cell)

func _on_plant_cell_clicked(cell: Vector2i) -> void:
	if selection_manager.get_selected() == null:
		return
	if BoardStateManager.is_valid_plant_placement(cell):
		place_plant(cell)

func place_plant(cell: Vector2i) -> void:
	print("plant placed on %d %d" % [cell.y, cell.x])

# ──────── zombie functions ──────────

func _handle_zombie_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var cell = BoardStateManager.world_to_cell(get_viewport().get_mouse_position())
			_on_zombie_cell_clicked(cell)

func _on_zombie_cell_clicked(cell: Vector2i) -> void:
	if selection_manager.get_selected() == null:
		return
	if BoardStateManager.is_valid_zombie_placement(cell):
		spawn_zombie(cell)

func spawn_zombie(cell: Vector2i) -> void:
	print("Zombie placed on %d %d" % [cell.y, cell.x])

# ──────── shared functions ──────────

func _update_cursor(cell: Vector2i) -> void:
	var role = NetworkManager.player_roles.get(multiplayer.get_unique_id(), "")
	var card_selected = selection_manager.get_selected() != null
	var in_zone = (role == "plant" and BoardStateManager.is_plant_zone(cell)) or (role == "zombie" and BoardStateManager.is_zombie_zone(cell))
	
	cursor_control.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if card_selected and in_zone else Control.CURSOR_ARROW

func _update_highlight(cell: Vector2i) -> void:
	var role = NetworkManager.player_roles.get(multiplayer.get_unique_id(), "")
	var card_selected = selection_manager.get_selected() != null
	var in_zone = (role == "plant" and BoardStateManager.is_plant_zone(cell)) or (role == "zombie" and BoardStateManager.is_zombie_zone(cell))

	if card_selected and in_zone:
		_place_highlight(BoardStateManager.cell_to_world(cell))
	else:
		_remove_highlight()

func _place_highlight(cell: Vector2) -> void:
	highlight.visible = true
	highlight.position = cell - BoardStateManager.TILE_SIZE / 2

func _remove_highlight() -> void:
	highlight.visible = false
					
