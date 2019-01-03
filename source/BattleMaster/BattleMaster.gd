extends Spatial

#The server battlemaster will RPC the involved players
#And the involved players will RPC back to the server

#The game will have Action points
#Which you spend on building structures

var playerOne
var playerTwo

const NUM_ACTION_POINTS = 4

var turn = 1

var phase = 1


func _ready():
	playerOne = $PlayerOne
	playerTwo = $PlayerTwo
	pass

func _process(delta):
	pass

func tick():
	phase += 1
	
	match(phase):
		1: pass
	
	pass

func refresh(player):
	#Refresh action points
	player.actionPoints = NUM_ACTION_POINTS
	
	#for effect in player.refreshEffects:
	#	pass
	
	#Refresh cards
	#for card in player.activeCards:
	#	pass
	#pass
	
master func drawCard(player):
	var card = player.drawCard()
	pass