"""
Goals for this tool:
[DONE]Zoom in and out
	-Rotate the map
	-[IN PROGRESS]Undo/Redo Functionality
[DONE]Pan across the map
	-Add or remove height layers
	-Add or remove entities and objects
	-Export levels
	-Easily navigate height layers

Notes for this project:
	- Water should be disabled after layer 1
	- Tiles should automatically be their full version on layer 1 and larger versions
	  on all subsequent layers
	- It might not be a bad idea to load in levels, like the actual base level
	  scene. Because the dictionary might end up being quite useful for when:
		We rotate the map
		The Bucket function
		The Save function itself
		Guaranteeing that it'll work in the game.
		Setting entities, traps and status effectrs onto tiles.
		

features implemented:
	Choose paintbrush to paint tiles onto a single layer
	Right-click while painting to erase a tile.

"""



extends Control

onready var timer       = Timer.new()
onready var astar       = AStar2D.new()
onready var tilemap     = $TileMap
onready var map_size    = map_sizes[5]
var map_sizes           = \
[Vector2(2,2),    #0
Vector2(4,4),     #1
Vector2(8,8),     #2
Vector2(16,16),   #3
Vector2(32,32),   #4
Vector2(64,64),   #5
Vector2(128,128)] #6

var map_heights = \
	[4,  #0
	9,   #1
	25,  #2
	49,  #3
	81,  #4
	121, #5
	169, #6
	225] #7


var atlas                 = {}
var threedarray           = []
enum I \
	{
	VALUE
	COORD
	}


enum Tool \
	{
# Make sure these are placed in the same order they appear in on the toolbar
# Otherwise you'll completely break the entire tools system D:
	PEN
	BUCKET
	NOTPEN
	ALLBUCKET
	LAYER
	PAN
	ERASER
	RECTANGLE
	OVAL
	}

var selected_tool         = Tool.PEN
var previous_tool         = null

var mainmenu              = "res://Scenes/Major Scenes/Main_Menu.tscn"
var font_resource         = load(
	"res://Resources/Font/Roboto Mono/RobotoMono-Bold.ttf")
var script_path           = "res://Scripts/Map_Editor/Map_Editor.gd"

var selected_tile         = 0
var tilechangearray       = []

var blank_tile            = 0
var mousedown             = false
var ignorekeys            = false
var ogtilemap
var mouseheld
var panactive             = false

var camera_zoom_factor    = 0.2

var timeline_array        = []
var timeline_value        = []
var timeline              = {}
var eventcounter          = -1
#==============================================================================#
#================================ Pre-Startup =================================#
#==============================================================================#

var console:TextEdit
var filebutton:MenuButton
var gridcontainer:GridContainer
var tileselector:ItemList
var toolbar:ItemList
var tilescrollbar:ScrollContainer
var reference_counter = 0
var expected_references = 6
var start_time = null

func _self_reference(node, node_name):
	if start_time == null:
		start_time = OS.get_system_time_msecs()
	match node_name:

		"Console":
			console = node
			reference_counter += 1
			print(console.name, " Path Connection Successful")
			return

		"FileButton":
			filebutton = node
			reference_counter += 1
			print(filebutton.name, " Path Connection Successful")
			return
		
		"GridContainer":
			gridcontainer = node
			reference_counter += 1
			print(gridcontainer.name, " Path Connection Successful")
		
		"Tile_Selector":
			tileselector = node
			reference_counter += 1
			print(tileselector.name, " Path Connection Successful")
			
		"Toolbar":
			toolbar = node
			reference_counter += 1
			print(toolbar.name, " Path Connection Successful")

		"Tile_Scrollbar":
			tilescrollbar = node
			reference_counter += 1
			print(tilescrollbar.name, " Path Connection Successful")

		_:
			printerr(node.name, " Failed to connect to root node correctly")

func add_syntax_highlighting():
	var dynamic_font = DynamicFont.new()
	dynamic_font.font_data = font_resource
	console.add_font_override("font", dynamic_font)
	
#	console.add_color_region('(', ')', Color(0.342621, 0.804688, 0.609753))
	console.add_color_region('#', '', Color(0.460938, 0.460938, 0.460938), true)
	
	var red_array = \
	['selected','Selected','tile','tiles','Tile','Tiles','tool','Tool']

	for word in red_array:
		console.add_keyword_color(word, Color(1, 0.019531, 0.019531))

	for id in tilemap.tile_set.get_tiles_ids():
		var text = tilemap.tile_set.tile_get_name(id)
		console.add_keyword_color(text, Color(0.419608, 0.380392, 1))

# warning-ignore:integer_division
	for index in toolbar.get_item_count():
		if toolbar.get_item_tooltip(index) != "":
			var text = toolbar.get_item_tooltip(index)
			console.add_keyword_color(text, Color(0.342621, 0.804688, 0.609753))

func filebutton_ready():
	filebutton.get_popup().add_item("Open Map File")
	filebutton.get_popup().add_item("Open Script File")
	filebutton.get_popup().add_item("Save Map File")
	filebutton.get_popup().add_item("Save Script File")
	filebutton.get_popup().add_item("Quit")
	
# warning-ignore:return_value_discarded
	filebutton.get_popup().connect("id_pressed", self, "_on_filebutton_pressed")

#==============================================================================#
#============================= Startup Functions ==============================#
#==============================================================================#

func _ready():
	prepare_toolbar()
	populate_tile_selector()
	prepare_tilemap()
	populate_atlas()
	add_syntax_highlighting()
	filebutton_ready()
	prepare_astar()
	timer.connect("timeout", self, "_on_timer_timeout")
	timer.wait_time = 0.02
	timer.one_shot = true
	timer.process_mode = Timer.TIMER_PROCESS_PHYSICS
	self.add_child(timer)
	console.text = " = Map Editor Successfully Loaded = "
	print("Ready!, Map editor took ", OS.get_system_time_msecs() - start_time, "ms to start")

func populate_tile_selector():
	tileselector.icon_mode = 0
	for id in tilemap.tile_set.get_tiles_ids():
		var tile_name = tilemap.tile_set.tile_get_name(id)
		var region = tilemap.tile_set.tile_get_region(id)
		var icon = tilemap.tile_set.tile_get_texture(id)
		
		if tile_name == "Gridline":
			tileselector.add_item("")
		tileselector.add_item(" ", icon)
		tileselector.set_item_icon_region(id, region)
#		tileselector.set_item_text(id, tile_name)
		tileselector.set_item_tooltip_enabled(id, false)
		tileselector.set_item_tooltip(id, tile_name)
	#Removes that one weird tile that always shows up at the end.
	tileselector.remove_item(tileselector.get_item_count()-1)

func prepare_tilemap():
	var gridline
	var count = tileselector.get_item_count()

	for i in range(count):
		if tileselector.get_item_tooltip(i) == "Gridline":
			gridline = i

	for x in range(map_size.x):
		for y in range(map_size.y):
			var tile = Vector2(x, y)
			tilemap.set_cellv(tile, gridline)

func populate_atlas():
	for y in range(map_size.y):
		for x in range(map_size.x):
			var coord = Vector2(x, y)
			var index = calculate_index(coord)
			var value = tilemap.get_cellv(coord)
			atlas[int(index)] = [value, coord]

func prepare_toolbar():
	var counter = 0
	for i in Tool:
		if counter >= toolbar.get_item_count():
			break
		toolbar.set_item_tooltip_enabled(counter, true)
		toolbar.set_item_tooltip(counter, i)
		counter += 1

func prepare_astar():
	for tile in tilemap.get_used_cells():
		var index = calculate_index(tile)
		astar.add_point(index, tile, 1)

	for tile in tilemap.get_used_cells():
		var index = calculate_index(tile)
		var points_relative = [
			tile + Vector2(1, 0),
			tile + Vector2(-1, 0),
			tile + Vector2(0, 1),
			tile + Vector2(0, -1)]
		
		for point in points_relative:
			var point_index = calculate_index(point)
			if not astar.has_point(point_index):
				continue
		#If the point we're finding connections for is along the map's y edge
			if point.y == 0 or point.y == map_size.y - 1:
				#If the index we're checking is more than one column width away
				if abs(point_index - index) > map_size.x:
					continue

		#If the point we're finding connections for is along the map's x edge
			if point.x == 0 or point.x == map_size.x - 1:
				#I actually don't remember how this one works.
				if abs(point_index - index) == 1:
					continue

		#if the point we're checking is negative or larger than the map bounds
			if point.y < 0 or point.y > map_size.y - 1\
			or point.x < 0 or point.x > map_size.x - 1:
				continue
			astar.connect_points(index, point_index, true)

#==============================================================================#
#============================== Input Handling ================================#
#==============================================================================#

func _process(_delta):
	match selected_tool:

		Tool.PEN:
			if mousedown == true:
				#Compensation for tilemap Zoom level and Panning
				var pos = get_local_mouse_position()
				pos = pos - tilemap.position
				pos = pos / tilemap.scale
				paint_tile(tilemap.world_to_map(pos))

		Tool.ERASER:
			if mousedown == true:
				#Compensation for tilemap Zoom level and Panning
				var pos = get_local_mouse_position()
				pos = pos - tilemap.position
				pos = pos / tilemap.scale
				paint_tile(tilemap.world_to_map(pos), blank_tile)

		Tool.NOTPEN:
			if mousedown == true:
				#Compensation for tilemap Zoom level and Panning
				var pos = get_local_mouse_position()
				pos = pos - tilemap.position
				pos = pos / tilemap.scale
				paint_tile(tilemap.world_to_map(pos))
		Tool.PAN:
			if mousedown == true:
				tilemap.position = get_local_mouse_position() - mouseheld + ogtilemap


func _input(event):# Used for actions that are universal regardless of tool
	# CTRL + Z
	if event is InputEventKey:
		# On Key Down
		if ignorekeys == false:
			if event.scancode == KEY_Z:
				if event.control:
					ignorekeys = true
					print("Keys will now be ignored")
		# On Key Up
		if ignorekeys == true:
			if event.pressed == false:
				ignorekeys = false
				print("Keys will no longer be ignored")

func _on_TilemapContainer_gui_input(event):
	match selected_tool:
		Tool.PEN:
			#Click to paint tiles selected tile
			if event.is_action_pressed("mouse_left_click"):
				mousedown = true
			if event.is_action_released("mouse_left_click"):
				var t = tilechangearray
				mousedown = false
				if t.size() > 9:
					print_to_console(str("Tiles ",t[0]," ",t[1]," ",t[2]," ",t[3]," ",\
					t[4]," and ",t.size()," more were set to ",\
					tileselector.get_item_tooltip(selected_tile)))
				elif t.size() > 0:
					print_to_console(str("Tiles ", t, " were set to ", \
					tileselector.get_item_tooltip(selected_tile)))
				else:
					return
				add_to_timeline(selected_tile, tilechangearray)
				tilechangearray.clear()

			#Right Click to Erase Tiles
			if event.is_action_pressed("mouse_right_click"):
				selected_tool = Tool.ERASER
				previous_tool = Tool.PEN
				mousedown = true
		Tool.ERASER:
			if event.is_action_released("mouse_right_click"):
				selected_tool = previous_tool
				mousedown = false
				var t = tilechangearray
				if t.size() > 9:
					print_to_console(str("Tiles ",t[0]," ",t[1]," ",t[2]," ",t[3]," ",\
					t[4]," and ",t.size()," more were erased"))
				elif t.size() > 0:
					print_to_console(str("Tiles ", t, " were erased"))
				else:
					return
				add_to_timeline(blank_tile, tilechangearray)
				tilechangearray.clear()

		Tool.BUCKET:
			var time = OS.get_system_time_msecs()
			if event.is_action_pressed("mouse_left_click"):
				var pos = get_local_mouse_position()
				var coord
				var index
				var value
				pos = pos - tilemap.position
				pos = pos / tilemap.scale
				coord = tilemap.world_to_map(pos)
				value = tilemap.get_cellv(coord)
				index = calculate_index(coord)
				mousedown = true
				bucket_paint(index, value, selected_tile)
				print("Bucket fill took ", OS.get_system_time_msecs() - time, "ms to finish")

			if event.is_action_released("mouse_left_click"):
				mousedown = false
		Tool.ALLBUCKET:
			if event.is_action_pressed("mouse_left_click"):
				var pos = get_local_mouse_position()
				var coord
				var index
				var value
				pos = pos - tilemap.position
				pos = pos / tilemap.scale
				coord = tilemap.world_to_map(pos)
				value = tilemap.get_cellv(coord)
				index = calculate_index(coord)
				mousedown = true
				var array = tilemap.get_used_cells_by_id(value)
				for i in array:
					paint_tile(i)
					print("Run?")
			if event.is_action_released("mouse_left_click"):
				mousedown = false

		Tool.NOTPEN:
			#Click to paint tiles selected tile
			if event.is_action_pressed("mouse_left_click"):
				mousedown = true
			if event.is_action_released("mouse_left_click"):
				var t = tilechangearray
				mousedown = false
				if t.size() > 9:
					print_to_console(str("Tiles ",t[0]," ",t[1]," ",t[2]," ",t[3]," ",\
					t[4]," and ",t.size()," more were set to ",\
					tileselector.get_item_tooltip(selected_tile)))
				elif t.size() > 0:
					print_to_console(str("Tiles ", t, " were set to ", \
					tileselector.get_item_tooltip(selected_tile)))
				else:
					return
				add_to_timeline(selected_tile, tilechangearray)
				tilechangearray.clear()

			#Right Click to Erase Tiles
			if event.is_action_pressed("mouse_right_click"):
				selected_tool = Tool.ERASER
				previous_tool = Tool.NOTPEN
				mousedown = true

#Functions independant of selected tool

	#Zoom Out
	if event.is_action_pressed("ui_page_down"):
		var step = camera_zoom_factor
		var zoom = tilemap.scale.x * step
		tilemap.scale.x = stepify(tilemap.scale.x - zoom, 0.1)
		tilemap.scale.y = stepify(tilemap.scale.y - zoom, 0.1)

	#Zoom In
	if event.is_action_pressed("ui_page_up"):
		var step = camera_zoom_factor
		var zoom = tilemap.scale.x * step

#Maximum limit you can zoom in
		if tilemap.scale >= Vector2(16, 16):
			tilemap.scale = Vector2(16, 16)
			return
#Prevents
		if tilemap.scale == Vector2(step, step):
			tilemap.scale = Vector2(step+zoom, step+zoom)
			pass

		tilemap.scale.x = stepify(tilemap.scale.x + zoom, 0.1)
		tilemap.scale.y = stepify(tilemap.scale.y + zoom, 0.1)
	#Panning
	if event is InputEventMouseButton:
		if event.is_action_pressed("mouse_middle_click"):
			#If the current tool is already pan don't change anything
			if selected_tool == Tool.PAN:
				pass
			else:
				previous_tool = selected_tool
			selected_tool = Tool.PAN
	
			mousedown = true
			mouseheld = get_global_mouse_position()
			ogtilemap = tilemap.position
		if event.is_action_released("mouse_middle_click"):
			selected_tool = previous_tool
			mousedown = false

#Kinda hacky workaround to avoid the itemlist and scrollcontainer both accepting
#scrolling input from the player. This is a bug in Godot and this is the only
#currently viable workaround.
func _on_ScrollContainer_gui_input(event):
	if event.is_action_pressed("mouse_left_click"):
		var pos = get_local_mouse_position()
		pos.y += tilescrollbar.scroll_vertical
		selected_tile = tileselector.get_item_at_position(pos)
		tileselector.select(selected_tile)
		tileselector.emit_signal("item_selected", selected_tile)
		print(pos)

#==============================================================================#
#============================= Console Functions ==============================#
#==============================================================================#

func print_to_console(text):
	console.text += str("\n", text)
	console.scroll_vertical = console.get_line_count() - 1

func _on_Console_text_changed():
	print("console.get_end()")

#==============================================================================#
#=============================== Menu Functions ===============================#
#==============================================================================#

func _on_filebutton_pressed(index):
	var itemname = filebutton.get_popup().get_item_text(index)
	match index:
		0:#Open Map File
			print(itemname)
		1:#Open Script File
			print(itemname)
		2:#Save Map File
			print(itemname)
		3:#Save Script File
			print(itemname)
		4:#Quit
			print(itemname)
			get_tree().quit()


#==============================================================================#
#=============================== Tool Functions ===============================#
#==============================================================================#

func _change_tool(new_tool):
	new_tool = new_tool
	pass

func _on_Toolbar_item_selected(index):
	selected_tool = index
	print_to_console(str("Selected tool is ", toolbar.get_item_tooltip(index)))

#==============================================================================#
#========================== Tile Selector Functions ===========================#
#==============================================================================#

func _on_Tile_Selector_item_selected(index):
	var itemname = tileselector.get_item_tooltip(index)
	var text = str("Selected tile is ", itemname)
	selected_tile = index
	print_to_console(text)

#==============================================================================#
#=========================== Tile Painter Functions ===========================#
#==============================================================================#

func paint_tile(tilemap_position, tile_value = selected_tile):
	var index = calculate_index(tilemap_position)
	if tilemap_position.x < 0 or tilemap_position.y < 0:
		return
	if tilemap_position.x > map_size.x-1 or tilemap_position.y > map_size.y-1:
		return
	if tilemap.get_cellv(tilemap_position) == tile_value:
		return
	if selected_tool == Tool.NOTPEN:
		if atlas[index][I.VALUE] > 0:
			return
	tilemap.set_cellv(tilemap_position, tile_value)
	atlas[index][I.VALUE] = tile_value
	tilechangearray.append(tilemap_position)

func bucket_paint(_index, tile_value, bucket_value = selected_tile):
	var search_from  = [_index]
	var search_to    = []
	var searched     = []
	var x = map_size.x


	while search_from.size() > 0:
#If there are no tiles to search from, break loop
		if search_from == []:
			break
		for index in search_from:
			if searched.has(index):
				continue
			for ii in astar.get_point_connections(index):
				if search_from.has(ii) or search_to.has(ii) or searched.has(ii):
					continue
				if atlas[int(ii)][I.VALUE] != tile_value:
					continue
				else:
					search_to.append(ii)
			searched.append(index)
		for ind in search_from:
			var coord = atlas[int(ind)][I.COORD]
			paint_tile(coord)
		timer.start()
		yield(timer, "timeout")
		

		search_from = search_to
		search_to = []
func _on_timer_timeout():
	pass
#==============================================================================#
#========================== Undo and Redo Functions ===========================#
#==============================================================================#

func calculate_index(vec:Vector2):
	return int(vec.x + (map_size.x * vec.y))
func calculate_vector(index:int):
	var point = Vector2.ZERO
	point.y     = int(index / map_size.x)
	point.x     = index - (point.y * map_size.x)
	return point

func add_to_timeline(value, array):
	eventcounter += 1
	var fillerarray = []
	for coord in array:
		fillerarray.append(calculate_index(coord))
	timeline[eventcounter] = {"Value": value, "Array": fillerarray}
