extends Control

var credits_scroll = false
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _input(event):
	if event.is_action_pressed("ui_back") and credits_scroll == true:
		Switch_Menu(0)
		

func _process(delta):
	if credits_scroll:
		var credits = get_node("Credits")
		
		if credits.margin_top <= -1 * (credits.get_rect().size.y + 600):
			credits.margin_top = 0
			credits.margin_bottom = 1469
		else:
			credits.margin_top -= 1
			credits.margin_bottom -= 1
	
func Switch_Menu(menu):
	var Menus = [
		get_node("Main Menu"),
		get_node("Credits"),
		get_node("Options Menu"),
		get_node("Pause Panel"),
		get_node("Game Over Menu"),
		get_node("Game View")
	]
	
	for Menu in Menus:
		Menu.hide()
	
	Menus[menu].show()
	credits_scroll = false;
	
	match menu:
		0: 
			find_node("Play Button").grab_focus()
		1:
			credits_scroll = true;
			var credits = get_node("Credits")
			credits.margin_top = 0
			credits.margin_bottom = 1469
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
	find_node("Game View").show()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _on_Play_Button_pressed():
	find_node("Main Menu").hide()
#
func _on_Main_Menu_Button3_pressed():
	get_tree().reload_current_scene()


func _on_Exit_To_Desktop_pressed():
	get_tree().quit()
