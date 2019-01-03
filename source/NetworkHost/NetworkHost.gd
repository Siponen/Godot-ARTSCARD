extends Node

#The Network Server is both a player, and the host.

const SERVER_IP = "127.0.0.1"
const SERVER_PORT = 8080
const MAX_PLAYERS = 10
const HOST_ID = 1

var tree
var peer

var onConnectPlayerData = {"name": "Host"}  #Init info we send to the server on connecting
var hostPlayerData = {}
var playerDataMap = {} #Player info, associate ID to data

func _ready():
	tree = get_tree()
	tree.connect("network_peer_connected", self, "onPlayerConnected")
	tree.connect("network_peer_disconnected", self, "onPlayerDisconnected")
	tree.connect("connected_to_server", self, "onConnectedOk")
	tree.connect("connection_failed", self, "onConnectedFail")
	tree.connect("server_disconnected", self, "onServerDisconnected")
	hostPlayerData = onConnectPlayerData
	pass

func getPlayers():
	var players = []
	var index = 0
	players.resize(playerDataMap.size())
	players.push_front({"id":HOST_ID, "name": hostPlayerData.name})
	for playerId in playerDataMap:
		var elem = playerDataMap[playerId]
		players[index] = {"id": playerId, "name":elem.name}
		index += 1
	return players

#Game RPG's
#There is also the get_rpc_sender_id function in SceneTree which can be used to check which peer (or peer ID) sent a RPC call.
remote func say(id, msg):
	pass

#func setPlayerName(_id,_newName):
#	playerDataMap[_id].name = _newName
#	Console.addLog(playerDataMap[_id].name + " changed name to " + _newName)
#	pass

#Network events
func onConnectedOk():
	Console.addLog("Server started on " + SERVER_IP + ":" + str(SERVER_PORT))
	pass

func onPlayerConnected(id):
	addPlayer()
	Console.addLog("Player " + str(id) + " connected")

func onPlayerDisconnected(id):
	playerDataMap.erase(id)
	Console.addLog("Player " + str(id) + " disconnected")
	
func onServerDisconnected():
	Console.addLog("Server disconnected")

func onConnectedFail():
	Console.addLog("Failed to connect to server " + SERVER_IP + ":" + str(SERVER_PORT))

remote func registerPlayer(id, playerData):
	if tree.is_network_server(): #As server: Register player to all other players
		for playerId in playerDataMap:
			rpc_id(playerId, "addPlayer", id, playerData)
			
	playerDataMap[id] = playerData #Store the playerData
	
	if tree.is_network_server(): #As server Give the connected all the player data
		for playerId in playerDataMap:
			rpc_id(id, "addPlayer", playerId, playerDataMap[playerId])
	
	#Update UI for host
	pass

remote func setPlayerName(_newName):
	var senderId = tree.get_rpc_sender_id()
	if playerDataMap.has(senderId) and tree.is_network_server():
		Console.addLog(playerDataMap[senderId].name + " changed name to " + _newName)
		playerDataMap[senderId].name = _newName
		#setPlayerName(_id, _newName)
	pass

remote func requestChangeName(_name):
	var id = tree.get_rpc_sender_id()
	if tree.is_network_server() and playerDataMap.has(id):
		var isNameCollision = false
		var highestId = 0
		
		for playerId in playerDataMap: #Check for name collision with all players, if a collision is found. Add an extra id number (1) to it.
			var elem = playerDataMap[playerId]
			if elem.name == _name: #Name Collision
				isNameCollision = true
				var pos = _name.find_last('(')
				if pos > 0: #The collided name already has a number, find it and compare for others.
					var number = int(_name[pos+1])
					if number > highestId:
						highestId = number
						
		if isNameCollision:
			_name += ("(" + str(highestId+1) + ")")

		#Make the change on the host
		playerDataMap[id].name = _name

		#Announce the new name to all players
		for playerId in playerDataMap:
			rpc_id(playerId, "setPlayerName", id, _name)
	pass

remote func addPlayer(id, playerData):
	playerDataMap[id] = playerData