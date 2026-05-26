extends Node

# FOR DEBUGGING REMOVE LATER
@export var debug_mode: bool = true
@export var debug_role: String = "plant"

var plant_player_id: int = -1
var zombie_player_id: int = -1

func _ready() -> void:
	# FOR DEBUGGING REMOVE LATER
	if debug_mode:
		_setup_debug()
		return
	if multiplayer.is_server():
		_assign_roles()

# assign player roles based on the selection from the lobby
func _assign_roles() -> void:
	var all_peers: Array =  Array(multiplayer.get_peers())
	all_peers.append(multiplayer.get_unique_id())

	for peer_id in all_peers:
		if not NetworkManager.player_roles.has(peer_id):
			push_error("Role not found for peer: " + str(peer_id))
			continue
		if NetworkManager.player_roles[peer_id] == "plant":
			plant_player_id = peer_id
		else:
			zombie_player_id = peer_id

	_sync_roles.rpc(plant_player_id, zombie_player_id)

@rpc("authority", "call_local", "reliable")
func _sync_roles(plant_id: int, zombie_id: int) -> void:
	plant_player_id = plant_id
	zombie_player_id = zombie_id

	var my_id = multiplayer.get_unique_id()
	if my_id == plant_id:
		print("I am Plant")
	else:
		print("I am Zombie")


# FOR DEBUGGING REMOVE LATER
func _setup_debug() -> void:
	var fake_id = multiplayer.get_unique_id()
	NetworkManager.player_roles[fake_id] = debug_role
	plant_player_id = fake_id if debug_role == "plant" else -1
	zombie_player_id = fake_id if debug_role == "zombie" else -1
	print("Debug mode: playing as ", debug_role)
