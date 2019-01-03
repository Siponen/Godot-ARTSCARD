extends Node

#The Network Server is both a player, and the host.
const SERVER_IP = "127.0.0.1"
const SERVER_PORT = 8080
const MAX_PLAYERS = 10
const HOST_ID = 1
var tree
var root
var peer

#Player data
var onConnectPlayerData #Init player info

var hostPlayerData #Ingame Host player info
var playerDataMap = {} #Ingame Client player info

var Player = preload("res://source/Player/Player.tscn")

func _ready():
	tree = get_tree()
	root = tree.get_root().get_node("Root")
	tree.connect("network_peer_connected", self, "onPlayerConnected")
	tree.connect("network_peer_disconnected", self, "onPlayerDisconnected")
	tree.connect("connected_to_server", self, "onConnectedOk")
	tree.connect("connection_failed", self, "onConnectedFail")
	tree.connect("server_disconnected", self, "onServerDisconnected")
	
	hostPlayerData = {"name": "HOST", "position": Vector3()} #Host player info
	onConnectPlayerData = {"name": "Player", "position": Vector3()}
	
	initNetwork()
	addPlayerToScene(HOST_ID, hostPlayerData)
	pass

func initNetwork():
	peer = NetworkedMultiplayerENet.new()
	var result = peer.create_server(SERVER_PORT, MAX_PLAYERS)
	if result == OK:
		Console.addLog("Hosting local server...")
	else:
		peer.create_client(SERVER_IP, SERVER_PORT)
		Console.addLog("Joining local server")

	get_tree().set_network_peer(peer)
	get_tree().set_meta("network_peer", peer)
	
	if get_tree().is_network_server():
		hostPlayerData = onConnectPlayerData
	pass

func getPlayers():
	var players = []
	var index = 1
	players.resize(playerDataMap.size())
	players.push_front({"id":HOST_ID, "name": hostPlayerData.name})
	for playerId in playerDataMap:
		var elem = playerDataMap[playerId]
		players[index] = {"id": playerId, "name":elem.name}
		index += 1
	return players

#Game RPG's
#There is also the get_rpc_sender_id function in SceneTree which can be used to check which peer (or peer ID) sent a RPC call.
#remote func say(id, msg):
#	pass

#Network events
func onConnectedOk():
	Console.addLog("Server connected on " + SERVER_IP + ":" + str(SERVER_PORT))
	var id = get_tree().get_network_unique_id()
	rpc("registerPlayer", id , onConnectPlayerData)
	pass

func onPlayerConnected(id):
	Console.addLog("Player " + str(id) + " connected")

func onPlayerDisconnected(id):
	if get_tree().is_network_server() and playerDataMap.has(id):
		removePlayer(id) #Remove the player from server
		for playerId in playerDataMap: #Tell other players to remove the player from their game.
			rpc_id(playerId, "removePlayerForClient", id)

	Console.addLog("Player " + str(id) + " disconnected")
	
func onServerDisconnected():
	Console.addLog("Server disconnected")

func onConnectedFail():
	Console.addLog("Failed to connect to server " + SERVER_IP + ":" + str(SERVER_PORT))


remote func registerPlayer(id, playerData):
	if tree.is_network_server():
		randomize() #Generate spawnpoint
		var spawnPosition = Vector3(randf()*2.0,0,randf()*2.0)
		playerData.position = spawnPosition
		#Register player to all other players
		for playerId in playerDataMap:
			rpc_id(playerId, "addPlayer", id, playerData)
		#Add the player to the server
		addPlayer(id, playerData)
		#Send all players to the new player
		for playerId in playerDataMap:
			rpc_id(id, "addPlayer", playerId, playerDataMap[playerId])
	pass

remote func addPlayer(id, playerData):
	playerDataMap[id] = playerData
	addPlayerToScene(id, playerData)

func addPlayerToScene(id, playerData):
	var player = preload("res://source/Player/Player.tscn").instance()
	root.get_node("Players").add_child(player)
	player.name = str(id)
	player.set_network_master(id)
	player.global_transform.origin = playerData.position


func hostChangeName(_name):
	if tree.is_network_server():
		var nextName = GetNextVacantName(_name)
		setHostPlayerName(nextName) #Make the change on the host
		for playerId in playerDataMap: #Announce the change to clients
			rpc_id(playerId, "setHostPlayerNameForClient", nextName)
	pass

remote func setHostPlayerNameForClient(newName):
	if get_tree().get_rpc_sender_id() == HOST_ID and typeof(newName) == TYPE_STRING:
		setHostPlayerName(newName)

func setHostPlayerName(newName):
	Console.addLog(hostPlayerData.name + " changed name to " + newName)
	hostPlayerData.name = newName

remote func requestClientChangeName(_name):
	var id = tree.get_rpc_sender_id()
	if tree.is_network_server() and playerDataMap.has(id):
		var nextName = GetNextVacantName(_name)
		setPlayerName(id, nextName ) # Make the change on the host
		for playerId in playerDataMap: #Announce the new name to all players
			rpc_id(playerId, "setClientPlayerName", id, nextName)
	pass

func GetNextVacantName(_name):
	var isNameCollision = false
	var highestId = 0
	#Check for name collision with all players, if a collision is found. Add an extra id number (1) to it.
	for playerId in playerDataMap:
		var elem = playerDataMap[playerId]
		if elem.name == _name: #Name collision happened
			isNameCollision = true
			var pos = _name.find_last('(')
			if pos > 0: #The collided name already has a number, find it and compare for others.
				var number = int(_name[pos+1])
				if number > highestId:
					highestId = number
					
	if isNameCollision:
		_name += ("(" + str(highestId+1) + ")")
	return _name

remote func setClientPlayerName(id, _newName):
	if playerDataMap.has(id):
		setPlayerName(id, _newName)
	pass

func setPlayerName(id, newName):
	Console.addLog(playerDataMap[id].name + " changed name to " + newName)
	playerDataMap[id].name = newName


remote func removePlayerForClient(id):
	if playerDataMap.has(id):
		removePlayer(id)
	pass

func removePlayer(id):
	playerDataMap.erase(id)
	var player = root.get_node("Players").get_node(str(id))
	root.get_node("Players").remove_child(player)
	player.queue_free()
	pass


func hostSay(msg):
	Console.addLog(hostPlayerData.name + ": " + msg) #Announce on server
	#Announce the say for each player
	for playerId in playerDataMap:
		rpc_id(playerId, "clientSay", HOST_ID, msg)
		pass
	pass

remote func requestClientSay(msg):
	var senderId = get_tree().get_rpc_sender_id()
	if playerDataMap.has(senderId) and typeof(msg) == TYPE_STRING:
		var player = playerDataMap[senderId]
		#Execute the say on server side
		Console.addLog(player.name + ": Server" + msg)
		#Announce say to all clients
		for playerId in playerDataMap:
			rpc_id(playerId, "clientSay", senderId, msg)

remote func clientSay(id, msg):
	if playerDataMap.has(id):
		var player = playerDataMap[id]
		Console.addLog(player.name + ": " + msg)
	pass

remote func requestMove(velocity):
	pass