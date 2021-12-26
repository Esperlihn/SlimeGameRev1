extends Control



onready var tilemap     = get_node("TileMap")

var mainmenu            = "res://Scenes/Major Scenes/Main_Menu.tscn"
var font_resource       = load("res://Resources/Font/droid-sans/DroidSans.ttf")
var script_path         = "res://Scripts/Map_Editor/Map_Editor.gd"
var active_tile         = 0
onready var scrollcontainer = get_node(str("M/V/H/Workspace_and_Menu/Right/",\
	"Right_Toolbar/Upper_Right_Tool/Blocks/ScrollContainer"))



func _ready():
	print("Ready")
	for id in tilemap.tile_set.get_tiles_ids():
		print(id, " ", tilemap.tile_set.tile_get_name(id))

#func _process(delta):

func _gui_input(event):
	if event.is_action_type():
		print("Ah")

#	if event.is_action_pressed("mouse_left_click"):
#		print(tilemap.world_to_map(get_global_mouse_position()))
#		var position = get_global_mouse_position() - Vector2(224, 4)
#		tilemap.set_cellv(tilemap.world_to_map(position), active_tile)


func _on_ReturnToMenu_pressed():
	assert(!get_tree().change_scene(mainmenu))


func _on_Viewport_gui_focus_changed(node):
	print(node)
	
func add_syntax_highlighting():
	pass
	var dynamic_font = DynamicFont.new()
	dynamic_font.font_data = font_resource
	console.add_font_override("font", dynamic_font)
	
	console.add_color_region('"', '"', Color(0.964706, 0.632077, 0.058824))
	console.add_color_region("'", "'", Color(0.964706, 0.632077, 0.058824))
	console.add_color_region('#', '', Color(0.460938, 0.460938, 0.460938), true)
	
	var red_array = ['func', 'print', 'var', 'onready', 'assert','extends', 'true',\
	'false','in', 'range', 'export', 'signal','void','null']
	var numbers_array = ['0', '1','2','3','4','5','6','7','8','9',]
	var pink_array = ['pass', 'if', 'for', 'return', 'match']

	for word in red_array:
		console.add_keyword_color(word, Color(0.558594, 0.111282, 0.111282))
	for number in numbers_array:
		console.add_keyword_color(number, Color(0.342621, 0.804688, 0.609753))
	for word in pink_array:
		console.add_keyword_color(word, Color(0.746929, 0.342621, 0.804688))
	
func filebutton_ready():
	filebutton.get_popup().add_item("Open Map File")
	filebutton.get_popup().add_item("Open Script File")
	filebutton.get_popup().add_item("Save Map File")
	filebutton.get_popup().add_item("Save Script File")
	filebutton.get_popup().add_item("Quit")
	
	filebutton.get_popup().connect("id_pressed", self, "_on_filebutton_pressed")
	
func _on_filebutton_pressed(index):
	var itemname = filebutton.get_popup().get_item_text(index)
	match index:
		0:#Open File
			print(itemname)
		1:#Save File
			print(itemname)
			var window = WindowDialog.new()
			self.add_child(window)
			window.popup_centered_ratio()
		2:#Quit
			print(itemname)
			get_tree().quit()




var console#:TextEdit
var filebutton#:MenuButton
var gridcontainer:GridContainer
var itemlist:ItemList
var reference_counter = 0
var expected_references = 15

func _self_reference(node, node_name):
	match node_name:

		"Console":
			console = node
			reference_counter += 1
			print(console.name, " Path Connection Successful")
			add_syntax_highlighting()
			var file = File.new()
			file.open(script_path, File.READ)
			var content = file.get_as_text()
			console.text = content
			return

		"FileButton":
			filebutton = node
			reference_counter += 1
			print(filebutton.name, " Path Connection Successful")
			filebutton_ready()
			return
		
		"GridContainer":
			gridcontainer = node
			reference_counter += 1
			print(gridcontainer.name, " Path Connection Successful")
		
		"ItemList":
			itemlist = node
			reference_counter += 1
			print(itemlist.name, "Path Connection Successful")

		_:
			printerr(node.name, " Failed to connect to root node correctly")
