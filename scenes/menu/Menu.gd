extends Control

const MATCHMAKING_URL = "http://localhost:3000"

@onready var host_button: Button = $VBoxContainer/HostButton
@onready var join_button: Button = $VBoxContainer/JoinButton
@onready var code_input: LineEdit = $VBoxContainer/CodeInput
@onready var status_label: RichTextLabel = $VBoxContainer/StatusLabel

func _ready() -> void:
	NetworkManager.connected_to_host.connect(_on_connected)
	NetworkManager.guest_joined.connect(_on_guest_joined)
	NetworkManager.connection_failed.connect(_on_failed)

# ─── Host Flow ───────────────────────────────────────────

func _on_host_button_pressed() -> void:
	NetworkManager.host_game()
	status_label.text = "Registering room..."
	host_button.disabled = true
	join_button.disabled = true
	_register_room()

func _register_room() -> void:
	var http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_on_room_registered)
	var body = JSON.stringify({"ip": _get_local_ip(), "port": 7777})
	var headers = ["Content-Type: application/json"]
	http.request(MATCHMAKING_URL + "/create", headers, HTTPClient.METHOD_POST, body)

func _on_room_registered(_result, response_code, _headers, body) -> void:
	if response_code != 200:
		status_label.text = "Server error. Is your matchmaking server running?"
		return
	var data = JSON.parse_string(body.get_string_from_utf8())
	var code = data["code"]
	status_label.text = "Room Code: " + code + "\nShare this with your friend!"

# ─── Join Flow ───────────────────────────────────────────

func _on_join_button_pressed() -> void:
	var code = code_input.text.strip_edges().to_upper()
	if code.length() == 0:
		status_label.text = "Enter a room code first"
		return
	status_label.text = "Looking up room..."
	host_button.disabled = true
	join_button.disabled = true
	_lookup_room(code)

func _lookup_room(code: String) -> void:
	var http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_on_room_found)
	http.request(MATCHMAKING_URL + "/join/" + code)

func _on_room_found(_result, response_code, _headers, body) -> void:
	if response_code == 404:
		status_label.text = "Room not found. Check the code."
		_reset_buttons()
		return
	var data = JSON.parse_string(body.get_string_from_utf8())
	status_label.text = "Connecting..."
	NetworkManager.join_game(data["ip"])

# ─── Connection Callbacks ─────────────────────────────────

func _on_connected() -> void:
	status_label.text = "Connected! Waiting for host to start..."

func _on_guest_joined() -> void:
	status_label.text = "Guest connected! Starting..."
	NetworkManager.go_to_lobby()

func _on_failed() -> void:
	status_label.text = "Connection failed. Try again."
	_reset_buttons()

# ─── Helpers ─────────────────────────────────────────────

func _reset_buttons() -> void:
	host_button.disabled = false
	join_button.disabled = false

func _get_local_ip() -> String:
	for address in IP.get_local_addresses():
		if address.begins_with("192.") or address.begins_with("10."):
			return address
	return "127.0.0.1"
