extends Control



onready var resolution_button =\
 get_node("HBoxContainer/VBoxContainer2/Settings/Resolution/OptionButton")
signal backpressed

var resolutions = [
	Vector2(640, 360),
	Vector2(960, 540),
	Vector2(1024, 576),
	Vector2(1138, 640),
	Vector2(1280, 720),
	Vector2(1600, 900),
	Vector2(1920, 1080),
	Vector2(2048, 1152),
	Vector2(2560, 1440),
	Vector2(3840, 2160),
	Vector2(4480, 2520),
	Vector2(5120, 2880),
	]

func _ready():
	if connect("backpressed", get_node(".."), "_on_Options_pressed"):
		printerr("Failed to connect options menu to main menu")
	var index = -1
	for i in resolutions:
		index += 1
		resolution_button.add_item(str(i.x, " x ", i.y), index)
		print(resolution_button.items[index])
		if i > OS.get_screen_size():
			resolution_button.set_item_disabled(index, true)


func _on_FullScreen_toggled(_button_pressed):
	if OS.window_fullscreen == false:
		OS.window_fullscreen = true
	else:
		OS.window_fullscreen = false

func _on_OptionButton_item_selected(index):
	var requested_resolution = str2vec2(resolution_button.get_item_text(index))
	if requested_resolution > OS.get_screen_size():
		return
	OS.set_window_size(requested_resolution)
	OS.center_window()

func _on_Back_pressed():
	emit_signal("backpressed")

func _on_Borderless_toggle_toggled(_button_pressed):
	if OS.window_borderless == true:
		OS.window_borderless = false
	else:
		OS.window_borderless = true


func str2vec2(string):
	var vec2 = Vector2.ZERO
	string.erase(string.find("x"),1)
	string.erase(string.find("("),1)
	string.erase(string.find(")"),1)
	string.erase(string.find(","),1)
	var x = string.left(string.find(" "))
	var y = string.right(string.find(" "))
	vec2 = Vector2(x,y)
	return vec2
