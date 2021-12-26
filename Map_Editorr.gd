extends Control

var mainmenu = "res://Scenes/Major Scenes/Main_Menu.tscn"
onready var tilemap = get_node("TileMap")

var menubutton
var reference_counter = 0
func _self_reference(node):
	match node:
		"MenuButton":
			menubutton = node
			reference_counter += 1
			print(menubutton.name, " Path Connection Successful")
			return

func _on_ReturnToMenu_pressed():
	assert(!get_tree().change_scene(mainmenu))

func _gui_input(event):
	if event.is_action_pressed("ui_page_down"):
		pass
	if event.is_action_pressed("mouse_left_click"):
		print("Clicked")
		print(tilemap.world_to_map(get_global_mouse_position()))


func _on_Viewport_gui_focus_changed(node):
	print(node)
