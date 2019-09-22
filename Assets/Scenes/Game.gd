extends Node

var playing = false
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	var play_button = find_node("Play Button")
	play_button.connect("pressed", self, "_on_Game_Started")
	
	var end_button = find_node("Main Menu Button")
	end_button.connect("pressed", self, "_on_Game_Ended")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#=func _process(delta):
#	pass

func _input(event):
	if event.is_action_pressed("game_pause"):
		if playing == true:
			playing = false
			find_node("Pause Panel").show()
			find_node("Resume Button").grab_focus();
			get_tree().paused = true
		else:
			playing = true
			find_node("Pause Panel").hide()
			get_tree().paused = false	

func _on_Game_Started():
	print("Game started!")
	playing = true

func _on_Game_Ended():
	print("Gamed!")
	playing = false