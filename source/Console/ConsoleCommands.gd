var tree
var root
var network
const HOST_ID = 1

func _init(_tree, _network):
	tree = _tree
	root = _tree.get_root().get_node("Root")
	network = root.get_node("Network")
	pass

func networkId():
	Console.addLog("Your network id is: " + str(network.networkId))

func say(message):
	if tree.is_network_server():
		network.hostSay(message)
	else:
		network.rpc_id(HOST_ID,"requestClientSay", message)
	pass

func changeName(theName):
	if tree.is_network_server():
		network.hostChangeName(theName)
	else:
		network.rpc_id(HOST_ID,"requestClientChangeName", theName)
	pass
	
func players():
	Console.addLog("Player list:")
	var playerList = network.getPlayers()
	for player in playerList:
		Console.addLog(str(player.id) + " " + player.name)
	pass

func connect(address):
	var pos = address.find(':')
	var ip = address.left(pos)
	var port = address.right(pos+1)
	
	if ip.empty() or port.empty():
		Console.addLog("connect invalid address, use '127.0.0.1:PORT_NUMBER'")
		return
	
	tree.set_network_peer(null)
	var result = network.peer.create_client(ip,int(port))
	if result == OK:
		Console.addLog("Connecting to " + ip + ":" + str(port) + "...")
	else:
		Console.addLog("Failed connect to " + ip + ":" + str(port))
	pass