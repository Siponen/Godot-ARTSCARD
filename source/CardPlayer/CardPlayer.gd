extends Spatial

var hand = []
var deck = []
var graveyard = []
#var banished = []

func _ready():
	pass

master func loadDeck():
	pass

master func drawCard(player):
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

slave func _physics_process(delta):
	if Input.is_action_just_pressed("select"):
		#Raycast for selection for mouse:
		var ray_length = 1000
		var mouse_pos = get_viewport().get_mouse_position()
		var camera = $Camera #Access the 'Camera' node
		var from = camera.project_ray_origin(mouse_pos)
		var to = from + camera.project_ray_normal(mouse_pos) * ray_length 
		var space_state = get_world().direct_space_state
		var collidedObject = space_state.intersect_ray(from, to, [self])
	pass