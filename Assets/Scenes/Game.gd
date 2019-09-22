extends Node

var playing = false
var blocks = preload("res://Assets/Tower/tower_blocks.tscn").instance()
var new_block
var should_lock_block = false

var ortho_bases = [
	Basis(Vector3( 1,  0, 0), Vector3(0, 1, 0), Vector3(0, 0, 1)),
	Basis(Vector3( 0, -1, 0), Vector3(1, 0, 0), Vector3(0, 0, 1)),
	Basis(Vector3(-1,  0, 0), Vector3(0, -1, 0), Vector3(0, 0, 1)),
	Basis(Vector3( 0,  1, 0), Vector3(-1, 0, 0), Vector3(0, 0, 1)),
	Basis(Vector3( 1,  0, 0), Vector3(0, 0, -1), Vector3(0, 1, 0)),
	Basis(Vector3( 0,  0, 1), Vector3(1, 0, 0), Vector3(0, 1, 0)),
	Basis(Vector3(-1,  0, 0), Vector3(0, 0, 1), Vector3(0, 1, 0)),
	Basis(Vector3( 0,  0, -1), Vector3(-1, 0, 0), Vector3(0, 1, 0)),
	Basis(Vector3( 1,  0, 0), Vector3(0, -1, 0), Vector3(0, 0, -1)),
	Basis(Vector3( 0,  1, 0), Vector3(1, 0, 0), Vector3(0, 0, -1)),
	Basis(Vector3(-1,  0, 0), Vector3(0, 1, 0), Vector3(0, 0, -1)),
	Basis(Vector3( 0, -1, 0), Vector3(-1, 0, 0), Vector3(0, 0, -1)),
	Basis(Vector3( 1,  0, 0), Vector3(0, 0, 1), Vector3(0, -1, 0)),
	Basis(Vector3( 0,  0, -1), Vector3(1, 0, 0), Vector3(0, -1, 0)),
	Basis(Vector3(-1,  0, 0), Vector3(0, 0, -1), Vector3(0, -1, 0)),
	Basis(Vector3( 0,  0, 1), Vector3(-1, 0, 0), Vector3(0, -1, 0)),
	Basis(Vector3( 0,  0, 1), Vector3(0, 1, 0), Vector3(-1, 0, 0)),
	Basis(Vector3( 0, -1, 0), Vector3(0, 0, 1), Vector3(-1, 0, 0)),
	Basis(Vector3( 0,  0, -1), Vector3(0, -1, 0), Vector3(-1, 0, 0)),
	Basis(Vector3( 0,  1, 0), Vector3(0, 0, -1), Vector3(-1, 0, 0)),
	Basis(Vector3( 0,  0, 1), Vector3(0, -1, 0), Vector3(1, 0, 0)),
	Basis(Vector3( 0,  1, 0), Vector3(0, 0, 1), Vector3(1, 0, 0)),
	Basis(Vector3( 0,  0, -1), Vector3(0, 1, 0), Vector3(1, 0, 0)),
	Basis(Vector3( 0, -1, 0), Vector3(0, 0, -1), Vector3(1, 0, 0))]

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
			
	if event is InputEventKey and event.pressed:
		if event.scancode == KEY_F5:
			get_tree().reload_current_scene()
	
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == BUTTON_LEFT:
	
			if rand_range(0, 1) > 0.5:
				new_block = blocks.get_node("Bent_Block").duplicate()
			else:
				new_block = blocks.get_node("Straight_Block").duplicate()
				
			add_child(new_block)
			new_block.set_identity()
			new_block.global_translate(Vector3(0, 20, rand_range(-6, 6)))
			new_block.connect("sleeping_state_changed", self, "_block_is_sleeping")

func _on_Game_Started():
	print("Game started!")
	playing = true

func _on_Game_Ended():
	print("Gamed!")
	playing = false
	
func _block_is_sleeping():
	should_lock_block = true
	
func _physics_process(delta):
	if should_lock_block:
		should_lock_block = false

		var rotation = Basis(Vector3(1,0,0), 1.5708 * floor((new_block.rotation_degrees.x + 45)/90))
		var y = int(new_block.transform.origin.y + .5) + int(new_block.transform.origin.y + .5) % 2 - 1
		var z = int(new_block.transform.origin.z + .5) + int(new_block.transform.origin.z + .5) % 2
		
		new_block.set_mode(RigidBody.MODE_STATIC)
		new_block.set_transform(Transform(rotation, Vector3(0, y, z)))