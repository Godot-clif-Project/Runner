extends Control

onready var label = $Label

func _ready():
	# Connect all the callbacks related to networking.
	NetworkManager.connect("peer_connected", self, "_player_connected")
	NetworkManager.connect("peer_disconnected", self, "_player_disconnected")
	NetworkManager.connect("connection_failed", self, "_connected_fail")
	NetworkManager.connect("connected_to_server", self, "_connected_ok")
	NetworkManager.connect("server_disconnected", self, "_server_disconnected")
	NetworkManager.connect("peer_registered", self, "update_peer_list")
	NetworkManager.lobby = self
	
	for item in $ResourcePreloader.get_resource_list():
		$LevelSelect.add_item(item)

#### Network callbacks from SceneTree ####

func _player_connected(_id):
	if get_tree().is_network_server():
		label.text = str(_id, " Client connected.")
		$StartNetGame.disabled = false
	else:
		label.text = "Connected to server."
#	$Ping.disabled = false

func _player_disconnected(_id):
	update_peer_list()
	if get_tree().is_network_server():
		label.text = str(_id, " Client disconnected.")
		if NetworkManager.peers.size() == 0:
			$StartNetGame.disabled = true
	else:
		# Assuming there are only two people:
		label.text = "Server disconnected."
		$Ping.disabled = true

func _connected_ok():
	update_gui(true)
	label.text = "Connected to server. Waiting for host to start game."
	pass

func _connected_fail():
	update_gui(false)
	label.text = "Couldn't connect to server."

func _server_disconnected():
	update_peer_list()
	update_gui(false)
	label.text = "Server disconnected."

func update_peer_list():
	$Peers.text = str(NetworkManager.peers)

func return_to_lobby():
	if NetworkManager.get_my_id() == 1:
		$StartNetGame.disabled = false
	update_peer_list()
	update_gui(true)

remotesync func start_net_game(level):
#	get_tree().paused = true
	self.queue_free()
	get_tree().root.add_child($ResourcePreloader.get_resource(level).instance())

func _on_Host_pressed():
	var port = int($Port.text)
	
	if not $Port.text.is_valid_integer() or port < 0 or port > 65535:
		label.text = "Port invalid."
	
	else:
		NetworkManager.my_info["name"] = $MyName.text
		NetworkManager.host_game(port)
		label.text = "Waitin' fo playa'..."
		update_gui(true)

func _on_Join_pressed():
	var port = int($Port.text)
	
	if not $Port.text.is_valid_integer() or port < 0 or port > 65535:
		label.text = "Port invalid."
		
	elif not $Adress.text.is_valid_ip_address():
		label.text = "Ip address invalid."
		
	else:
		NetworkManager.my_info["name"] = $MyName.text
		NetworkManager.join_game($Adress.text, port)
		label.text = "Waitin' fo serva'..."
		update_gui(true)

func _on_Disconnect_pressed():
	if get_tree().has_network_peer():
		NetworkManager.disconnect_network()
		label.text = "Disconnected."
	else:
		label.text = "No connections active."
	update_gui(false)
	update_peer_list()

func _on_Ping_pressed():
	if get_tree().has_network_peer():
		var status = get_tree().network_peer.get_connection_status()
		if status == NetworkedMultiplayerPeer.CONNECTION_CONNECTED and NetworkManager.peers.size() > 0:
			rpc("ping", get_tree().network_peer.get_unique_id())
		else:
			label.text = "No peers to ping to."
	else:
		label.text = "No connections active."
	pass # Replace with function body.

remote func ping(id):
	label.text = str("Received ping from ", NetworkManager.peers[id]["name"])
	rpc_id(id, "ping_back", get_tree().network_peer.get_unique_id())

remote func ping_back(id):
	label.text = str(NetworkManager.peers[id]["name"], " Pinged back.")

func _on_StartNetGame_pressed():
	if get_tree().has_network_peer():
		if NetworkManager.peers.size() == 0:
			label.text = "No peers to start game with."
		else:
			rpc("start_net_game", $LevelSelect.get_item_text($LevelSelect.selected))
	else:
		label.text = "No connections active."

func _on_StartSingleGame_pressed():
	NetworkManager.disconnect_network()
#	visible = false
	self.queue_free()
	get_tree().root.add_child($ResourcePreloader.get_resource($LevelSelect.get_item_text($LevelSelect.selected)).instance())

func _on_Port_text_changed(new_text):
	if new_text == "":
		$Port.text = str(NetworkManager.DEFAULT_PORT)

func _on_Adress_text_changed(new_text):
	if new_text == "":
		$Adress.text = "127.0.0.1"

func update_gui(is_connected):
	if is_connected:
		$Host.visible = false
		$Join.visible = false
		$Disconnect.visible = true
		$MyName.editable = false
		$Adress.editable = false
		$Port.editable = false
		$StartSingleGame.disabled = true
	else:
		$Host.visible = true
		$Join.visible = true
		$Disconnect.visible = false
		$MyName.editable = true
		$Adress.editable = true
		$Port.editable = true
		$Ping.disabled = true
		$StartSingleGame.disabled = false
		$StartNetGame.disabled = true
