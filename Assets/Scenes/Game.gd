extends Node

var blocks = preload("res://Assets/Tower/tower_blocks.tscn").instance()
var wizard
var camera
var occupancy_grid = []
var playing = false
var clicking = false
var should_lock_block = false
var block_is_free = false
var new_block


# Called when the node enters the scene tree for the first time.
func _ready():
	camera = get_node("Game Camera")
	wizard = get_node("Wizard")
	
	var play_button = find_node("Play Button")
	play_button.connect("pressed", self, "_on_Game_Started")
	
	var end_button = find_node("Main Menu Button")
	end_button.connect("pressed", self, "_on_Game_Ended")
	
	for y in range(100):
    	occupancy_grid.append([0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not block_is_free:
		_spawn_block()

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
			clicking = true
			
	elif event is InputEventMouseButton and not event.pressed:
			if event.button_index == BUTTON_LEFT:
				clicking = false

func _on_Game_Started():
	print("Game started!")
	playing = true

func _on_Game_Ended():
	print("Gamed!")
	playing = false
	
func _block_is_sleeping():
	should_lock_block = true

func _spawn_block():
	if rand_range(0, 1) > 0.5:
		new_block = blocks.get_node("Bent_Block").duplicate()
	else:
		new_block = blocks.get_node("Straight_Block").duplicate()
		
	add_child(new_block)
	new_block.set_identity()
	new_block.global_translate(Vector3(0, 20, rand_range(-6, 6)))
	new_block.rotate_x(rand_range(-2, 2))
	new_block.connect("sleeping_state_changed", self, "_block_is_sleeping")
	block_is_free = true

func _spawn_floor(y):
	var floor_block = blocks.get_node("Floor").duplicate()
	
	add_child(floor_block)
	floor_block.set_identity()
	floor_block.global_translate(Vector3(0, y, 0))
	

	var y_dif = y - wizard.transform.origin.y
	wizard.global_translate(Vector3(0, y_dif, 0))
	camera.global_translate(Vector3(0, y_dif, 0))

func _physics_process(delta):
	
	if block_is_free and clicking:
		var position = get_node("Mouse_Area/Position").transform.origin
		var force = new_block.transform.origin.direction_to(position)
		new_block.add_central_force(force * 20)
		
	if should_lock_block:
		should_lock_block = false
		block_is_free = false
	
		var rotation = Basis(Vector3(1,0,0), 1.5708 * floor((new_block.rotation_degrees.x + 45)/90))
		var y = int(new_block.transform.origin.y + .5) + int(new_block.transform.origin.y + .5) % 2 - 1
		var z = int(new_block.transform.origin.z + .5) + int(new_block.transform.origin.z + .5) % 2
		
		new_block.set_mode(RigidBody.MODE_STATIC)
		new_block.set_transform(Transform(rotation, Vector3(0, y, z)))
		
		y = floor(y / 2)
		z = floor(z / 2) + 10
		
		occupancy_grid[y][z] = 1
		
		var degrees = new_block.rotation_degrees.x

		if new_block.name.find("Straight_Block") != -1:
			if abs(degrees) < 10 or abs(degrees) > 170:
				occupancy_grid[y][z+1] = 1
				occupancy_grid[y][z-1] = 1
			else:
				occupancy_grid[y+1][z] = 1
				occupancy_grid[y-1][z] = 1
		else:
			if degrees > -10  and degrees < 10:
				occupancy_grid[y+1][z] = 1
				occupancy_grid[y][z+1] = 1
			elif degrees > 80  and degrees < 100:
				occupancy_grid[y][z+1] = 1
				occupancy_grid[y-1][z] = 1
			elif degrees > -100  and degrees < -80:
				occupancy_grid[y+1][z] = 1
				occupancy_grid[y][z-1] = 1
			else:
				occupancy_grid[y-1][z] = 1
				occupancy_grid[y][z-1] = 1

		if occupancy_grid[y].count(1) > 5:
			_spawn_floor(new_block.transform.origin.y)
		