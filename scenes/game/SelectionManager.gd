extends Node

signal unit_selected(unit_data: UnitData)

@export var plant_cards: Array[PlantData]
@export var zombie_cards: Array[ZombieData]

@onready var hand_container: HBoxContainer = $"../HandContainer"

const CARD_SCENE = preload("res://scenes/game/Card.tscn")

var selected_card: UnitData = null
var cards: Array[Card] = []

func _ready() -> void:
	var role = NetworkManager.player_roles[multiplayer.get_unique_id()]
	if role == "plant":
		_build_hand(plant_cards)
	else:
		_build_hand(zombie_cards)

func _build_hand(data_array: Array) -> void:
	for i in data_array.size():
		var card_instance = CARD_SCENE.instantiate()
		hand_container.add_child(card_instance)
		card_instance.setup(data_array[i])
		card_instance.card_selected.connect(_on_card_selected)
		cards.append(card_instance)

func _on_card_selected(unit_data: UnitData) -> void:
	selected_card = unit_data
	unit_selected.emit(unit_data)
	_update_visuals()

func _update_visuals() -> void:
	for card in cards:
		if card.unit_data == selected_card:
			card.modulate = Color(1.2, 1.2, 0.5)
		else:
			card.modulate = Color(1, 1, 1)

func _unhandled_input(event: InputEvent) -> void:
	# handle card selection using num keys
	if event is InputEventKey and event.pressed:
		var number_keys = [KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6]
		for i in number_keys.size():
			if event.keycode == number_keys[i] and i < cards.size():
				_on_card_selected(cards[i].unit_data)
				break
	
	# remove the selected visual on clicking outside a playable zone
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			var role = NetworkManager.player_roles[multiplayer.get_unique_id()]
			var cell = BoardStateManager.world_to_cell(get_viewport().get_mouse_position())
			var in_zone = BoardStateManager.is_plant_zone(cell) if role == "plant" else BoardStateManager.is_zombie_zone(cell)

			if not in_zone:
				selected_card = null
				_update_visuals()

func get_selected() -> UnitData:
	return selected_card
