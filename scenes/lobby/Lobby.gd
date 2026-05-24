extends Control

var local_role: String = ""
var opponent_role: String = ""
var local_ready: bool = false
var opponent_ready: bool = false
var countdown_active: bool = false
var countdown_cancelled: bool = false

@onready var role_label: Label = $VBoxContainer/RoleLabel
@onready var ready_button: Button = $VBoxContainer/ReadyButton
@onready var status_label: Label = $VBoxContainer/StatusLabel
@onready var plant_button: Button = $VBoxContainer/HBoxContainer/PlantButton
@onready var zombie_button: Button = $VBoxContainer/HBoxContainer/ZombieButton

func _ready() -> void:
	ready_button.disabled = true

# ─── Role Selection ───────────────────────────────────────

func _on_plant_button_pressed() -> void:
	if local_role == "plant":
		local_role = ""
		plant_button.button_pressed = false
		role_label.text = "No role selected"
	else:
		local_role = "plant"
		plant_button.button_pressed = true
		zombie_button.button_pressed = false
		role_label.text = "You are: Plants 🌱"

	_cancel_ready()
	_notify_role.rpc(multiplayer.get_unique_id(), local_role)

func _on_zombie_button_pressed() -> void:
	if local_role == "zombie":
		local_role = ""
		zombie_button.button_pressed = false
		role_label.text = "No role selected"
	else:
		local_role = "zombie"
		zombie_button.button_pressed = true
		plant_button.button_pressed = false
		role_label.text = "You are: Zombies 🧟"

	_cancel_ready()
	_notify_role.rpc(multiplayer.get_unique_id(), local_role)

# ─── Ready Up ─────────────────────────────────────────────

func _on_ready_button_pressed() -> void:
	if local_role == "":
		return
	local_ready = ready_button.button_pressed

	if local_ready:
		NetworkManager.register_role(multiplayer.get_unique_id(), local_role)

	if not local_ready and countdown_active:
		# Player unreadied during countdown
		_cancel_countdown.rpc()
		status_label.text = ""

	status_label.text = "Waiting for opponent..." if local_ready else ""
	_notify_ready.rpc(multiplayer.get_unique_id(), local_ready)
	_check_both_ready()

func _cancel_ready() -> void:
	local_ready = false
	ready_button.button_pressed = false
	ready_button.disabled = local_role == ""

# ─── RPCs ─────────────────────────────────────────────────

@rpc("any_peer", "call_local", "reliable")
func _notify_role(peer_id: int, role: String) -> void:
	if peer_id != multiplayer.get_unique_id():
		opponent_role = role
		_update_status()

func _update_status() -> void:
	if opponent_role == "" :
		status_label.text = "Opponent deselected role"
		return
	if local_role == opponent_role:
		status_label.text = "Role taken! Pick a different role."
		_cancel_ready()
		_notify_ready.rpc(multiplayer.get_unique_id(), false)
	else:
		status_label.text = "Opponent chose: " + opponent_role

@rpc("any_peer", "call_local", "reliable")
func _notify_ready(peer_id: int, is_ready: bool) -> void:
	if peer_id != multiplayer.get_unique_id():
		opponent_ready = is_ready
	_check_both_ready()

@rpc("any_peer", "call_local", "reliable")
func _cancel_countdown() -> void:
	countdown_cancelled = true
	countdown_active = false
	ready_button.disabled = false
	plant_button.disabled = false
	zombie_button.disabled = false
	status_label.text = ""

# ─── Start Logic ──────────────────────────────────────────

func _check_both_ready() -> void:
	if not local_ready or not opponent_ready:
		return
	if local_role == "" or opponent_role == "":
		status_label.text = "Both players must select a role!"
		return
	if local_role == opponent_role:
		status_label.text = "Both players must pick different roles!"
		return
	if multiplayer.is_server() and not countdown_active:
		_begin_countdown.rpc()

@rpc("authority", "call_local", "reliable")
func _begin_countdown() -> void:
	countdown_active = true
	countdown_cancelled = false
	ready_button.disabled = false  # keep enabled so players can unready
	plant_button.disabled = true
	zombie_button.disabled = true
	_run_countdown(5)

func _run_countdown(seconds: int) -> void:
	if countdown_cancelled:
		return
	status_label.text = "Game starting in " + str(seconds) + "..."
	if seconds == 0:
		if multiplayer.is_server():
			NetworkManager.start_game()
		return
	await get_tree().create_timer(1.0).timeout
	_run_countdown(seconds - 1)
