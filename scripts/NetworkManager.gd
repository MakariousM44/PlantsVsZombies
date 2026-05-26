extends Node

const PORT = 7777
const MAX_PEERS = 2

var peer: ENetMultiplayerPeer
var player_roles: Dictionary = {}

signal connected_to_host()
signal guest_joined()
signal connection_failed()

func _ready() -> void:
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.peer_connected.connect(_on_peer_connected)

func host_game() -> void:
	peer = ENetMultiplayerPeer.new()
	var err = peer.create_server(PORT, MAX_PEERS)
	if err != OK:
		push_error("Failed to host: " + str(err))
		return
	multiplayer.multiplayer_peer = peer

func join_game(ip: String) -> void:
	peer = ENetMultiplayerPeer.new()
	var err = peer.create_client(ip, PORT)
	if err != OK:
		push_error("Failed to join: " + str(err))
		return
	multiplayer.multiplayer_peer = peer

func go_to_lobby() -> void:
	get_tree().change_scene_to_file("res://scenes/lobby/Lobby.tscn")
	_load_lobby.rpc()

@rpc("authority", "call_remote", "reliable")
func _load_lobby() -> void:
	get_tree().change_scene_to_file("res://scenes/lobby/Lobby.tscn")

func start_game() -> void:
	# Host changes scene directly
	get_tree().change_scene_to_file("res://scenes/game/Game.tscn")
	# RPC tells guest to do the same
	_start_game.rpc()

@rpc("authority", "call_remote", "reliable")
func _start_game() -> void:
	get_tree().change_scene_to_file("res://scenes/game/Game.tscn")

func _on_connected_to_server() -> void:
	connected_to_host.emit()

func _on_connection_failed() -> void:
	connection_failed.emit()

func _on_peer_connected(_id: int) -> void:
	if multiplayer.is_server():
		guest_joined.emit()

func register_role(peer_id: int, role: String) -> void:
	player_roles[peer_id] = role
	_sync_role.rpc(peer_id, role)

@rpc("authority", "call_remote", "reliable")
func _sync_role(peer_id: int, role: String) -> void:
	player_roles[peer_id] = role
