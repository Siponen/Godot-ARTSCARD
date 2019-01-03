extends Node

var NetworkServer = preload("res://source/NetworkHost/NetworkHost.tscn")
var NetworkClient = preload("res://source/NetworkClient/NetworkClient.tscn")
var networkNode

const SERVER_IP = "127.0.0.1"
const SERVER_PORT = 8080
const MAX_PLAYERS = 10

func _ready():
	pass

func _process(delta):
	if Input.is_action_just_pressed("toggle_console"):
		Console.toggle()
		
func configureGame():
	pass