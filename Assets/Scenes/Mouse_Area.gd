extends Area

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _input_event(camera, event, pos, normal, shape):
	if (event is InputEventMouseMotion):
		get_node("Position").set_identity()
		get_node("Position").global_translate(pos)
		
		
