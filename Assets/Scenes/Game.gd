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
var at_floor = 0
var desired_floor_height = 3
var floor_offset = 0
var particles
var score = 0
var multiplier = 1
var seconds_of_play = 0
var last_aim_change = 0
var average_height = [5, 5, 5, 5, 5]

# Called when the node enters the scene tree for the first time.
func _ready():
	camera = get_node("Game Camera")
	wizard = get_node("Wizard")
	particles = get_node("Wizard/CPUParticles")
	
	var play_button = find_node("Play Button")
	play_button.connect("pressed", self, "_on_Game_Started")
	
	var end_button = find_node("Main Menu Button")
	end_button.connect("pressed", self, "on_Game_Over")
	
	occupancy_grid = [
		[1,1,1,1,1,1,1,1],
		[1,1,1,1,1,1,1,1],
		[1,1,1,1,1,1,1,1],
	]
	
	for i in range(0, 100):
		occupancy_grid.append([0,0,0,0,0,0,0,0])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if not playing:
		get_node("Mouse_Area").hide()
	else:
		get_node("Mouse_Area").show()
		
	if not block_is_free and playing:
		_spawn_block()

	var position = get_node("Mouse_Area/Position")
	
	if Input.is_action_pressed("aim_up"):
		position.global_translate(Vector3(0, 1, 0))
		last_aim_change = 1
	
	if Input.is_action_pressed("aim_down"):
		position.global_translate(Vector3(0, -1, 0))
		last_aim_change = 2
	
	if Input.is_action_pressed("aim_left"):
		position.global_translate(Vector3(0, 0, -1))
		last_aim_change = 3
		
	if Input.is_action_pressed("aim_right"):
		position.global_translate(Vector3(0, 0, 1))
		last_aim_change = 4
	
func _input(event):
	if event.is_action_pressed("game_pause") and playing:
		if playing == true:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			find_node("Pause Panel").show()
			find_node("Game View").hide()
			find_node("Resume Button").grab_focus();
			get_tree().paused = true
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
			find_node("Pause Panel").hide()
			find_node("Game View").show()
			get_tree().paused = false	
		
	if event.is_action_pressed("casting"):
		clicking = true
	
	if event.is_action_released("casting"):
		clicking = false
			
	if event.is_action_pressed("reset_aim"):
		get_node("Mouse_Area/Position").translation = Vector3(0, 8.412, 0)

func _on_Game_Started():
	print("Game started!")
	find_node("Game Camera").current = true
	find_node("Timer").start()
	find_node("Score Timer").start()
	find_node("Game Timer").start()
	find_node("Game View").show()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	playing = true

func _on_Game_Ended():
	print("Gamed!")
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().reload_current_scene()
	playing = false
	
func _on_Game_Over():
	playing = false

	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_node("Menu Camera").current = true
	find_node("Game View").hide()
	find_node("Game Over Menu").show()
	find_node("Main Menu Button3").grab_focus()
	
	find_node("Game Over Floors").text = "You built " + String(at_floor) + " " + ("floor" if at_floor == 1 else "floors")
	find_node("Game Over Survived").text = "Surived for " + format_time(seconds_of_play)
	find_node("Game Over Points").text = "and earned " + String(score) + " points"
	find_node("Game Over Applause").text = "Great Job!"

func format_time(time):
	var minutes = time / 60
	var seconds = time - (minutes * 60)
	return String(minutes) + " " + ("minute" if minutes == 1 else "minutes") + " and " + String(seconds) + (" second" if seconds == 1 else " seconds")
	
func _block_is_sleeping():
	should_lock_block = true

func _spawn_block():
	var tower = find_node("BaseTower")
	var thrust = 0
	if rand_range(0, 1) > 0.5:
		new_block = blocks.get_node("Bent_Block").duplicate()
		thrust = 700
	else:
		new_block = blocks.get_node("Straight_Block").duplicate()
		thrust = 950
		
	tower.add_child(new_block)
	new_block.set_identity()
	var dir = -1
	if rand_range(0, 1) > 0.5:
		dir = 1
		new_block.global_translate(Vector3(0, 3, rand_range(-10, -20)))
	else:
		new_block.global_translate(Vector3(0, 3, rand_range(10, 20)))
	new_block.rotate_x(rand_range(-2, 2))
	new_block.add_central_force(Vector3(0, thrust, 0))
	new_block.add_torque(Vector3(rand_range(0, 500*dir), 0, 0))
	new_block.connect("sleeping_state_changed", self, "_block_is_sleeping")
	block_is_free = true
	
func _destroy_bottom_floor():
	occupancy_grid.pop_front()
	occupancy_grid.append([0,0,0,0,0,0,0,0])
	floor_offset += 1
	var blocks = get_node("BaseTower").get_children()
	
	for block in blocks:
		block.global_translate(Vector3(0, -2, 0))
		
	wizard.global_translate(Vector3(0, -2, 0))
	
	if wizard.translation.y > -2:
		if wizard.translation.y <= 1:
			get_node("Warning").pitch_scale = 1.2
			get_node("Warning").play()
		elif wizard.translation.y <= 3:
			get_node("Warning").pitch_scale = 1.1
			get_node("Warning").play()
		elif wizard.translation.y <= 5:
			get_node("Warning").pitch_scale = 1
			get_node("Warning").play()

func _spawn_floor(y):
	var floor_block = blocks.get_node("Floor").duplicate()
	get_node("BaseTower").add_child(floor_block)
	floor_block.set_identity()
	floor_block.global_translate(Vector3(0, y+.8, 0))

	var y_dif = y - wizard.transform.origin.y
	wizard.global_translate(Vector3(0, desired_floor_height * 2, 0))
	
	for i in range(1, desired_floor_height + 2):
		occupancy_grid.append([0,0,0,0,0,0,0,0])

func _physics_process(delta):
	
	if new_block and block_is_free and clicking:
		var position = get_node("Mouse_Area/Position").transform.origin
		var force = new_block.transform.origin.direction_to(position)
		new_block.add_central_force(force * 20)
		particles.set_emitting(true)
		particles.set_gravity(particles.to_local(new_block.transform.origin))
	else:
		particles.set_emitting(false)	
	
	if should_lock_block:
		should_lock_block = false
		block_is_free = false
	
		var rotation = Basis(Vector3(1,0,0), 1.5708 * floor((new_block.rotation_degrees.x + 45)/90))
		var y = int(new_block.transform.origin.y + .5) + int(new_block.transform.origin.y + .5) % 2 - 1
		var z = int(new_block.transform.origin.z + .5) + int(new_block.transform.origin.z + .5) % 2
		
		new_block.set_mode(RigidBody.MODE_STATIC)
		new_block.set_transform(Transform(rotation, Vector3(0, y, z)))
		
		y = floor(y / 2)
		z = floor(z / 2) + 4
		
		if z >= 0 and z < occupancy_grid[y].size():
			occupancy_grid[y][z] = 1
		
		var degrees = new_block.rotation_degrees.x
		
		var targets = []
		if new_block.name.find("Straight_Block") != -1:
			if abs(degrees) < 10 or abs(degrees) > 170:
				targets.append(Vector2(y, z+1))
				targets.append(Vector2(y, z-1))
			else:
				targets.append(Vector2(y+1, z))
				targets.append(Vector2(y-1, z))
		else:
			if degrees > -10  and degrees < 10:
				targets.append(Vector2(y+1, z))
				targets.append(Vector2(y, z+1))
			elif degrees > 80  and degrees < 100:
				targets.append(Vector2(y, z+1))
				targets.append(Vector2(y-1, z))
			elif degrees > -100  and degrees < -80:
				targets.append(Vector2(y+1, z))
				targets.append(Vector2(y, z-1))
			else:
				targets.append(Vector2(y-1, z))
				targets.append(Vector2(y, z-1))
		for target in targets:
			if target.y >= 0 and target.y < occupancy_grid[target.x].size():
				occupancy_grid[target.x][target.y] = 1
		
		var floors_to_check = []
		for i in range(desired_floor_height * (at_floor + 1), desired_floor_height * (at_floor + 1) + desired_floor_height):
			floors_to_check.append(occupancy_grid[i - floor_offset])
		
		if floor_requirements_met(floors_to_check):
			at_floor += 1
			var floor_fill_count = 0
			
			for floor_to_check in floors_to_check:
				floor_fill_count += floor_to_check.count(1)
			
			var floor_fill_percent = round((float(floor_fill_count if floor_fill_count < 24 else floor_fill_count * 2) / 24) * 100)
			score += (1*floor_fill_percent*multiplier)
			find_node("Score Label").text = "Score: " + String(score)
			
			multiplier += 1
			average_height.pop_front()
			average_height.append(get_node("Wizard").translation.y)
			
			var average_height_multiplier = 0
			for height in average_height:
				average_height_multiplier += height
				
			average_height_multiplier = average_height_multiplier / average_height.size()
			
			get_node("Timer").wait_time = min(floor(100 / float(average_height_multiplier)), 25)
			print(get_node("Timer").wait_time)
			
			_spawn_floor((at_floor + 1)  * (desired_floor_height * 2) - (floor_offset * 2))
			for cell in occupancy_grid[at_floor * desired_floor_height -1]:
				cell = 1
				
func floor_requirements_met(floors):
	for i in range(0, floors.size()):
		if floors[i].count(1) < 5:
			return false
	return true
		
func _on_Mouse_Area_input_event(camera, event, pos, normal, shape):
	if(event is InputEventMouseMotion) and playing:
		var position = get_node("Mouse_Area/Position")
		position.set_identity()
		position.global_translate(pos)


func _on_Timer_timeout():
	_destroy_bottom_floor()
	find_node("Timer").start()
	pass
	
func _on_Area_body_entered(body):
	if body == new_block:
		new_block.queue_free()
		block_is_free = false
	elif body.get_parent() == find_node("BaseTower"):
		body.queue_free()
	if body == wizard.get_node("KinematicBody"):
		_on_Game_Over()


func _on_Score_Timer_timeout():
	score += 1 * multiplier
	find_node("Score Label").text = "Score: " + String(score)
	get_node("Score Timer").start()


func _on_Game_Timer_timeout():
	seconds_of_play += 1

func _on_Main_Menu_Button_pressed():
	get_tree().paused = false
	find_node("Pause Panel").hide()
	find_node("Game View").show()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	_on_Game_Over()
