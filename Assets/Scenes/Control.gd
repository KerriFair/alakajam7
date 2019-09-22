extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func Switch_Menu(menu):
	var Menus = [
		get_node("Main Menu"),
		get_node("Credits"),
		get_node("Options Menu"),
		get_node("Pause Panel")
	]
	
	for Menu in Menus:
		Menu.hide()
	
	Menus[menu].show()
	
	match menu:
		0: 
			find_node("Play Button").grab_focus()
		1:
			find_node("Credits Back Button").grab_focus()
		2:
			find_node("Fullscreen Toggle").grab_focus()
		3:
			find_node("Resume Button").grab_focus()
	
func _on_Options_Button_pressed():
	Switch_Menu(2)

func _on_Exit_Button_pressed():
	get_tree().quit()

func _on_Credits_Back_Button_pressed():
	Switch_Menu(0)

func _on_Options_Back_Button_pressed():
	Switch_Menu(0)

func _on_Credits_Button_pressed():
	Switch_Menu(1)

func _on_Fullscreen_Toggle_pressed():
	var toggle = find_node("Fullscreen Toggle")
	toggle.text = "ON" if toggle.text == "OFF" else "OFF"
	OS.window_fullscreen = true if toggle.text == "ON" else false

func _on_Borderless_Toggle_pressed():
	var toggle = find_node("Borderless Toggle")
	toggle.text = "ON" if toggle.text == "OFF" else "OFF"
	OS.window_borderless = true if toggle.text == "ON" else false

func _on_VSync_Toggle_pressed():
	var toggle = find_node("V-Sync Toggle")
	toggle.text = "ON" if toggle.text == "OFF" else "OFF"
	OS.vsync_enabled = true if toggle.text == "ON" else false

func _on_Volume_Button_pressed():
	var button = find_node("Volume Button")
	var volume = int(button.text.substr(0, button.text.length() - 1))
	
	if volume == 100:
		volume = 0
	else:
		volume += 5
		
	button.text = String(volume) + "%"
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear2db(float(volume)/100))
		
func _on_Main_Menu_Button_pressed():
	get_tree().paused = false
	Switch_Menu(0)
	find_node("Play Button").grab_focus()

func _on_Resume_Button_pressed():
	get_tree().paused = false
	find_node("Pause Panel").hide()

func _on_Play_Button_pressed():
	find_node("Main Menu").hide()

