extends Spatial

var displayName = "Player"

func _ready():
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

func setName(_name):
	displayName = _name
	$Viewport/Label.text = _name