extends Control

var Commands = preload("res://source/Console/ConsoleCommands.gd")
var commands

const MAX_LOG_LINES = 19
var numLogLines

const MAX_BUFFER_LINES = 20
var root

var isActive
var consoleLog
var consoleLogArray
var commandBuffer
var numCommandBufferElements
var animPlayer

signal add_log

func _ready():
	root = get_tree().get_root().get_node("Root")
	connect("add_log",self,"addLog")
	animPlayer = $AnimationPlayer
	commands = Commands.new(get_tree(), root.get_node("Network"))
	consoleLog = $ConsoleLog
	consoleLogArray = []
	consoleLogArray.resize(MAX_LOG_LINES)
	commandBuffer = []
	numCommandBufferElements = 0
	commandBuffer.resize(MAX_BUFFER_LINES)
	hide()
	isActive = false
	set_process_input(false)
	pass

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.scancode == KEY_ENTER:
			var commandString = $CmdLine.text
			addLog(commandString)
			parseCommand(commandString)
			commandBuffer.push_front(commandString)
			$CmdLine.text = ""

func toggle():
	if isActive:
		isActive = false
		animPlayer.play("close")
		$CmdLine.release_focus()
		$CmdLine.text = $CmdLine.text.replace('§','') #Since we cant ignore the Backslash (Tilde §) to be added. We have to replace it. Ugly, but I found no better workarounds
		set_process_input(false)
	else:
		animPlayer.play("open")
		isActive = true
		$CmdLine.grab_focus()
		set_process_input(true)
	pass

func addLog(msg):
	consoleLogArray.pop_back()
	consoleLogArray.push_front(msg)
	consoleLog.text = ""
	for i in range(consoleLogArray.size()-1, -1, -1):
		var elem =  consoleLogArray[i]
		if elem != null and not elem.empty(): 
			consoleLog.text += consoleLogArray[i] + "\n"
	pass

func parseCommand(command):
	var slices = command.split(' ', false, 2) #Slice[0] - Command, #Slice[1] - value
	var numSlices = slices.size()
	if numSlices == 2:
		match(slices[0]):
			"name": commands.changeName(slices[1])
			"connect": commands.connect(slices[1])
			"say": commands.say(slices[1])
	else:
		match(slices[0]):
			"players": commands.players()
			"networkId" : commands.networkId()