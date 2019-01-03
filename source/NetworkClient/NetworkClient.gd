extends Node

const SERVER_IP = "127.0.0.1"
const SERVER_PORT = 8080
const MAX_PLAYERS = 10
const HOST_ID = 1

var tree
var peer

var onConnectPlayerData = {"name": "Player"}  #Init info we send to the server on connecting
var clientId
var playerDataMap = {} #Player info, associate ID to data

func _ready():
	tree = get_tree()
	tree.connect("network_peer_connected", self, "onPlayerConnected")
	tree.connect("network_peer_disconnected", self, "onPlayerDisconnected")
	tree.connect("connected_to_server", self, "onConnectedOk")
	tree.connect("connection_failed", self, "onConnectedFail")
	tree.connect("server_disconnected", self, "onServerDisconnected")
	pass

func getPlayers():
	var players = []
	var index = 0
	players.resize(playerDataMap.size())
	for playerId in playerDataMap:
		var elem = playerDataMap[playerId]
		players[index] = {"id": playerId, "name":elem.name}
		index += 1
	return players

func onConnectedOk():
	clientId = get_tree().get_network_unique_id()
	rpc_id(1,"registerPlayer", clientId, onConnectPlayerData)
	Console.addLog("Connected to server " + SERVER_IP + ":" + str(SERVER_PORT))
	pass

sync func addPlayer(id, playerData):
	playerDataMap[id] = playerData #Store the playerData
	#Update UI
	pass

sync func setPlayerName(_id , _newName):
	if playerDataMap.has(_id):
		Console.addLog(playerDataMap[_id].name + " changed name to " + _newName)
		playerDataMap[_id].name = _newName
		setPlayerName(_id, _newName)
	pass

#Network events
func onPlayerConnected(id):
	Console.addLog("Player " + str(id) + " connected")

func onPlayerDisconnected(id):
	playerDataMap.erase(id)
	Console.addLog("Player " + str(id) + " disconnected")
	
func onServerDisconnected():
	Console.addLog("Server disconnected")

func onConnectedFail():
	Console.addLog("Failed to connect to server " + SERVER_IP + ":" + str(SERVER_PORT))