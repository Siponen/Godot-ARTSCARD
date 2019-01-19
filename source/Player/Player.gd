extends KinematicBody

enum PlayerState {IDLE = 1, PENDING_COMBAT ,COMBAT}
var currentState

var displayName = "Player"
var interactObject

var playerMovement = Vector3()
const GRAVITY = -24

func _ready():
	currentState = IDLE
	$InteractArea.connect("body_entered", self,"onNewInteraction")
	$InteractArea.connect("body_exited", self, "onRemoveInteraction")
	$UI/InteractUI.hide()
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

func setName(_name):
	displayName = _name
	$Viewport/Label.text = _name

func _physics_process(delta):
	if self.is_network_master():
		var velocity = Vector3()
		if Input.is_action_pressed("move_left"):
			velocity.x = 1
		if Input.is_action_pressed("move_right"):
			velocity.x = -1
		if Input.is_action_pressed("move_forward"):
			velocity.z = 1
		if Input.is_action_pressed("move_backward"):
			velocity.z = -1
		
		if Input.is_action_just_pressed("interact"):
			
			pass
		
		self.move_and_slide(velocity*100)
		
slave func client_input(delta):
	if Input.is_action_just_pressed("move_left"):
		rpc_id(Globals.HOST_ID, "onPlayerMoveLeftPressed")
		
	elif Input.is_action_just_released("move_left"):
		rpc_id(Globals.HOST_ID, "onPlayerMoveLeftReleased")
	
	if Input.is_action_just_pressed("move_right"):
		rpc_id(Globals.HOST_ID, "onPlayerMoveRightPressed")
		
	elif Input.is_action_just_released("move_right"):
		rpc_id(Globals.HOST_ID, "onPlayerMoveRightReleased")

	if Input.is_action_just_pressed("move_forward"):
		rpc_id(Globals.HOST_ID, "onPlayerMoveForwardPressed")
		
	elif Input.is_action_just_released("move_forward"):
		rpc_id(Globals.HOST_ID, "onPlayerMoveForwardReleased")
	
	if Input.is_action_just_pressed("move_backward"):
		rpc_id(Globals.HOST_ID, "onPlayerMoveBackwardPressed")
		
	elif Input.is_action_just_released("move_backward"):
		rpc_id(Globals.HOST_ID, "onPlayerMoveBackwardReleased")
	
	if Input.is_action_just_pressed("interact") and currentState == IDLE:
		rpc_id(Globals.HOST_ID, "onPlayerInteract")
		pass
	pass

sync func onPlayerMoveLeftPressed():
	var playerId = get_tree().get_rpc_sender_id()
	pass

sync func onPlayerMoveLeftReleased():
	pass

sync func onPlayerMoveRightPressed():
	pass

sync func onPlayerMoveRightReleased():
	pass

func changeInteractionObject(body):
	
	pass

func onNewInteraction(body):
	if body.has_method("interact"):
		setInteractionObject(body)
	pass
	
func onRemoveInteraction(body):
	if interactObject == null: return
	$UI/InteractUI.hide()
	interactObject = null
	pass

func setInteractionObject(object):
	$UI/InteractUI/ObjectLabel.text = object.id
	interactObject = object
	$UI/InteractUI.show()
	#object.setInteractionFocus()
	pass