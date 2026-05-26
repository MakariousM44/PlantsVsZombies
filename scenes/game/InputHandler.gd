extends Node

@onready var highlight = $"../Highlight"

var hovered_cell: Vector2i = Vector2i(-1, -1)

func _ready() -> void:
	pass

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var cell = BoardStateManager.world_to_cell(get_viewport().get_mouse_position())
		if cell != hovered_cell:
			hovered_cell = cell
			_on_cell_hovered(cell)

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
	if BoardStateManager.is_valid_zombie_placement(cell):
		spawn_zombie(cell)

func spawn_zombie(cell: Vector2i) -> void:
	print("Zombie placed on %d %d" % [cell.y, cell.x])

# ──────── shared functions ──────────

func _on_cell_hovered(cell: Vector2i) -> void:
	var role = NetworkManager.player_roles[multiplayer.get_unique_id()]

	if role == "plant" and BoardStateManager.is_plant_zone(cell):
		Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
		_place_highlight(BoardStateManager.cell_to_world(cell))
	elif role == "zombie" and BoardStateManager.is_zombie_zone(cell):
		Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
		_place_highlight(BoardStateManager.cell_to_world(cell))
	else:
		Input.set_default_cursor_shape(Input.CURSOR_ARROW)
		_remove_highlight()

func _place_highlight(cell: Vector2) -> void:
	highlight.visible = true
	highlight.position = cell - BoardStateManager.TILE_SIZE / 2

func _remove_highlight() -> void:
	highlight.visible = false