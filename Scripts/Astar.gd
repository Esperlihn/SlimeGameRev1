"""
This file is part of:
Lihnpixel Games
https://lihnpixel.ca
***********************
Copyright (c) 2020 -2021 Sukh Atwal
"""

extends TileMap

enum I {
	CELLVALUE,   #0
	COORDINATES, #1
	WALKABLE,    #2
	SWIMMABLE,   #3
	ROTATE90,    #4
	ROTATE180,   #5
	ROTATE270,   #6
	LAYER,       #7
	POSITION,    #8
	POSITION90,  #9
	POSITION180, #10
	POSITION270, #11
	ASTARCOORD,  #12
	INDEX90,     #13
	INDEX180,    #14
	INDEX270,    #15
	INDEX,       #16
	HIGHLIGHT,   #17
	}

onready var map_origin         = Vector2(get_used_rect().position.x, get_used_rect().position.y)
onready var map_size           = Vector2(get_used_rect().end.x, get_used_rect().end.y)
onready var map_center         = Vector2((map_size.x / 2) - 0.5, (map_size.y / 2) - 0.5)
onready var layerindexvalue    = map_size.x * map_size.y
onready var astar              = AStar.new()
onready var layers             = get_node("..").get_children()
onready var highlight          = preload("res://Scenes/Highlight Tile.tscn")
onready var camera             = get_node("../../Interactive HUD")
onready var timer              = get_node("../../Timer")
#onready var selecttile         = preload("res://Scenes/Select_highlight.tscn")


#=================================== DEBUG ====================================#
var linebreak = "\n==============================\n"
export var debug:bool
export(String, "up", "down") var boo #Choose between two options
export(int, 10, 20) var foo #export between range 10-20
#==============================================================================#
var layers_ascending           = []
var orientation                = 0
#var unwalkable_tiles           = []
var walkable_tiles             = []
var swimmable_tiles            = [1]
var used_tiles                 = []
var buffer_array               = []

var highlights                 = []
var used_highlights            = []
var highlightcount             = 0
var tileoffsets                = [0, 8, 0, 4, -2, 0]
var index_max_value            = 0
var dict                       = {}
var selecttileindex            = 0

var moverange                  = 25
var jumpheight                 = 1
var ignoremouseclicks          = false
var runningfunc                = 0
#==============================================================================#
#=========================== STARTUP ONLY FUNCTIONS ===========================#
#==============================================================================#

func _ready():
	OS.center_window()
	
	
	var time = OS.get_system_time_msecs()
	print(linebreak)
	
	camera.visible = true
	
	for _n in range(layers.size()):
		var l = layers.pop_back()
		layers_ascending.append(l)
		layers.push_front(l)

	index_max_value = map_size.x * map_size.y * layers.size() -1

	for l in layers:
		l.z_index = int(l.name)

	map_origin.x = clamp(map_origin.x, 0, 99999)
	map_origin.y = clamp(map_origin.y, 0, 99999)

	_populate_dict()
	_get_used_tiles()
	_add_walkable_tiles()
	_connect_walkable_tiles()
	_spawn_highlights()
#
#
#	OS.set_window_title("HEHEHE")
#	OS.alert("You're too adorable c:", "BEWARE")
#	get_tree().quit()
	
	print(\
	linebreak,\
	"\nMap origin: ",map_origin,\
	"\nMap edge: ",map_size,\
	"\nTotal Used tiles = ", used_tiles.size(), \
	"\nWalkable Tiles = ", walkable_tiles.size(), \
	"\nHighlight Tiles = ", highlightcount, \
	"\n\n==============================",\
	"\nSystem startup took ", OS.get_system_time_msecs() - time, " ms",\
	linebreak )
	

#func _process(delta):
#	print(Performance.TIME_FPS)

func _populate_dict():
	var time = OS.get_system_time_msecs()
	for x in range(0, map_size.x):
		for y in range(0, map_size.y):
			for z in range(0, layers.size()):
				var point = Vector3(x, y, z)
				var point_index = _calculate_index(point)
				point = Vector2(x, y)
				var layer = layers_ascending[z]
				dict[point_index] = \
				[
				#0 ---------------------CELLVALUE-------------------------------#
				-1,
				
				#1 ---------------------COORDINATE------------------------------#
				point,
				
				#2 ---------------------WALKABLE--------------------------------#
				false,
				
				#3 ---------------------SWIMMABLE-------------------------------#
				false,
				
				#4 ---------------------ROTATE90--------------------------------#
				_rotate_coords(point, "right"),
				
				#5 ---------------------ROTATE180-------------------------------#
				_rotate_coords(_rotate_coords(point, "right"), "right"),
				
				#6 ---------------------ROTATE270-------------------------------#
				_rotate_coords(point, "left"),
				
				
				#7 ---------------------LAYER-----------------------------------#
				layer,
				
				#8 ---------------------POSITION--------------------------------#
				map_to_world(point), 
				
				#9 ---------------------POSITION90------------------------------#
				_rotate_position(map_to_world(point), "right"), 
				
				#10 ---------------------POSITION180-----------------------------#
				_rotate_position(_rotate_position(map_to_world(point), "right"), "right"), 
				
				#11 ---------------------POSITION270-----------------------------#
				_rotate_position(map_to_world(point), "left"), 
				
				#12 ---------------------ASTARCOORDS ----------------------------#               
				Vector3(x, y, z),
				
				#13 ---------------------INDEX90--------------------------------#
				_calculate_index(_rotate_coords(Vector3(x, y, z), "right")),
				
				#14 --------------------INDEX180--------------------------------#
				_calculate_index(_rotate_coords(_rotate_coords(Vector3(x,y,z), "right"), "right")),
				
				#15 --------------------INDEX270--------------------------------#
				_calculate_index(_rotate_coords(Vector3(x, y, z), "left")),
				
				#16 --------------------INDEX-----------------------------------#
				_calculate_index(Vector3(x,y,z)),
				
				
				#----------------------BLANK SPACE BB--------------------------#
				]
	print("populate_dict ran in ", OS.get_system_time_msecs() - time, " ms")
func _get_used_tiles():
	var time = OS.get_system_time_msecs()
	
	for l in layers:
		var z = int(l.name)
		for cell in l.get_used_cells():
			if cell.x < map_origin.x or cell.y < map_origin.y or \
			cell.x > map_size.x or cell.y > map_size.y:
				l.set_cellv(cell, -1)
				continue
			var point_index = _calculate_index(Vector3(cell.x, cell.y, z))
			var value = l.get_cellv(cell)
			used_tiles.append(int(point_index))
			dict[point_index][I.CELLVALUE] = value
	print("Used tiles ran in ", OS.get_system_time_msecs() - time, " ms")
func _add_walkable_tiles():
	var time         = OS.get_system_time_msecs()
	var points_array = []
	var layer_size   = map_size.x * map_size.y

	for tile in used_tiles:
		if tile > index_max_value:
			continue
		var index = int(tile)
		var value = dict[index][I.CELLVALUE]
		var point = dict[index][I.ASTARCOORD]
#==============================================================================#
#		if unwalkable_tiles.has(index):
#			continue
		if value != 0:
			if swimmable_tiles.has(value):
				continue
#if the tile above is occupied, tile is not walkable
		if index + layer_size < index_max_value:
			if dict[int(index + layer_size)][I.CELLVALUE] != -1:
				continue
#If the next tile imemdiately above that is occupied. Tile is Still not walkable.
		else:
			if index + layer_size*2 < index_max_value:
				if dict[index + layer_size*2][I.CELLVALUE] != -1:
					continue
#==============================================================================#
		dict[index][I.WALKABLE] = true
		points_array.append(index)
		astar.add_point(index, point, 1)
	walkable_tiles = points_array

	print("add_walkable_tiles ran in ", OS.get_system_time_msecs() - time, " ms")
	return
func _connect_walkable_tiles():
	var time =  OS.get_system_time_msecs() 
	for point_index in walkable_tiles:
		var point = dict[point_index][I.ASTARCOORD]
		var points_relative = PoolVector3Array([
			point + Vector3(1, 0, 0),
			point + Vector3(-1, 0, 0),
			point + Vector3(0, 1, 0),
			point + Vector3(0, -1, 0),
			point + Vector3(1, 0, 1),
			point + Vector3(-1, 0, 1),
			point + Vector3(0, 1, 1),
			point + Vector3(0, -1, 1),
			point + Vector3(1, 0, -1),
			point + Vector3(-1, 0, -1),
			point + Vector3(0, 1, -1),
			point + Vector3(0, -1, -1),
		])
		for point_relative in points_relative:
			var point_relative_index = _calculate_index(point_relative)
			if not astar.has_point(point_relative_index):
				continue
#disables the ability for players to "wraparound" from one edge to another
			if point.y == 0 or point.y == map_size.y - 1:
				if abs(point_relative_index - point_index) > map_size.x:
					continue
			if point.x == 0 or point.x == map_size.x - 1:
				if abs(point_relative_index - point_index) == 1:
					continue

			astar.connect_points(point_index, point_relative_index, true)
	print("connect_walkable_tiles ran in ", OS.get_system_time_msecs() - time, " ms")
	return
func _spawn_highlights():
	var time = OS.get_system_time_msecs()
	var counter = used_tiles.size() * 1.25
	while highlightcount < counter:
		var r = highlight.instance()
		highlights.append(r)
		layers[0].add_child(r)
		r.position.y -= 32
		r.visible = false
		highlightcount += 1
	print("spawn_highlights ran in ", OS.get_system_time_msecs() - time, " ms")
	
#============================== INPUT FUNCTIONS ===============================#
#==============================================================================#

func _unhandled_input(event):
	if event.is_action_pressed("mouse_left_click"):
		if ignoremouseclicks == true:
			return
		else:
			_clear_highlights()
			set_highlights(_identify_tile(get_global_mouse_position()))
			print(selecttileindex)
	if event.is_action_pressed("ui_f11"):
		if OS.window_fullscreen == true:
			OS.window_borderless = false
			OS.window_fullscreen = false
		else:
			OS.window_borderless = true
			OS.window_fullscreen = true


#============================== ASTAR FUNCTIONS ===============================#
#==============================================================================#
#When a point is removed all connections to that point are also removed.
#however when a point is added, the connections to said point must be
#added manually. Thus why I made an add function but no remove one
func add_astar_point(index):
	var point = index_to_vector(index)
	astar.add_point(index, point)
	
	var x = 1
	var y = map_size.x
	var z = map_size.x * map_size.y
	var points_relative = PoolIntArray([
		index + x,
		index + -x,
		index + y,
		index + -y,
		index + x + z,
		index - x + z,
		index + y + z,
		index - y + z,
		index + x - z,
		index - x - z,
		index + y - z,
		index - y - z,
		])
	for neighbourindex in points_relative:
		if neighbourindex < 0 or neighbourindex > map_size.x * map_size.y:
			continue
		if not astar.has_point(neighbourindex):
			continue
		astar.connect_points(index, neighbourindex, true)

#============================= REGULAR FUNCTIONS ==============================#
#==============================================================================#

func _identify_tile(Position):
	var layer
	var finalpos
# warning-ignore:unused_variable
	var value
	var tile = Vector3.ZERO
	var array = []
	
	for l in layers:
		var pos = Position
		var v
		if l.name != "0":
			pos.y -= l.position.y + 17
		v = l.get_cellv(l.world_to_map(pos))
		pos.y -= tileoffsets[v]
		pos = l.world_to_map(pos)
		if v == -1 or null:
			continue
		else:
			layer = l
			finalpos = pos
			value = v
			break
	if typeof(finalpos) == 0:
		print("Selected position is not a valid target")
		return
	tile.x = finalpos.x
	tile.y = finalpos.y
	tile.z = int(layer.name)
	tile = _calculate_index(tile)
	match orientation:
		0:
			tile = dict[tile][I.INDEX]
		90:
			tile = dict[tile][I.INDEX270]
		180:
			tile = dict[tile][I.INDEX180]
		270:
			tile = dict[tile][I.INDEX90]
	array.append(tile)
	selecttileindex = tile
	return array

func set_highlights(array, color = Color8(0,0,255,255)):
	var time = OS.get_system_time_msecs()
	var string

	if typeof(array) == 0:
		print("Invalid point selected")
		return

	for index in array:
		var pos = dict[index][I.POSITION]
		match orientation:
			0:
				if debug == true:
					string = str("[center]", dict[index][I.INDEX], "[/center]")
			90:
				if debug == true:
					string = str("[center]", dict[index][I.INDEX90], "[/center]")
				pos = dict[index][I.POSITION90]
			180:
				if debug == true:
					string = str("[center]", dict[index][I.INDEX180], "[/center]")
				pos = dict[index][I.POSITION180]
			270:
				if debug == true:
					string = str("[center]", dict[index][I.INDEX270], "[/center]")
				pos = dict[index][I.POSITION270]
	
	
		var layer = dict[index][I.LAYER]
		var value = dict[index][I.CELLVALUE]
		var offset
	
		var highlighter = highlights.pop_front()
		highlighter.position = pos
		if index > layerindexvalue:
			highlighter.position.y += 15
		highlighter.position.y += tileoffsets[value]
		offset = highlighter.position.y - pos.y
	
		highlighter.get_parent().remove_child(highlighter)
		layer.add_child(highlighter)
		highlighter.visible = true
		if debug == true:
			highlighter.get_node("./Coordinate").visible = true
			highlighter.get_node("./Coordinate").bbcode_text = string
			highlighter.modulate = color
			highlighter.get_node("./Coordinate").self_modulate = Color.white
			used_highlights.append([highlighter, offset])
			continue
		highlighter.modulate = color

		used_highlights.append([highlighter, offset])
		buffer_array.append(highlighter)
	print("Set highlights took ", OS.get_system_time_msecs() - time, "ms to run")

func _clear_highlights():
	for _h in range(used_highlights.size()):
		var highlighter = used_highlights.pop_front()
		highlighter = highlighter[0]
		highlighter.visible = false
		highlighter.z_index = 0
		highlighter.position = Vector2(0, -32)
		highlights.append(highlighter)
func clear_map():
	for l in layers:
		l.clear()
	_clear_highlights()
	astar.clear()

#============================= ROTATION FUNCTIONS =============================#
#==============================================================================#

func _rotate_map(direction):
	var time = OS.get_system_time_msecs()
	var newrot

#setting new orientation
	if direction == "right":
		orientation  = wrapi(orientation + 90, 0, 360)
	if direction == "left":
		orientation  = wrapi(orientation - 90, 0, 360)

#adjusting coordinates to orientation
	match orientation:
		0:
			newrot = I.COORDINATES
		90:
			newrot = I.ROTATE90
		180:
			newrot = I.ROTATE180
		270:
			newrot = I.ROTATE270

#Clear Astar, All Tiles and all Highlights
#	clear_map()
	for l in layers:
		l.clear()
	astar.clear()

#Rotating all nonemptytiles
	for index in used_tiles:
		var tile = dict[index]
		tile[I.LAYER].set_cellv(tile[newrot], tile[I.CELLVALUE])
		
	for high in used_highlights:
		var offset = high[1]
		high = high[0]
		high.position = _rotate_position(high.position, direction)
		high.position.y += offset

#Rotating all currently active highlights.
#Replace this function in the future. I intend to use DICT to store a reference 
#To all objects on it, highlights, enemies, players, objects, statuses, Anything that can
#be instanced. So that these things can quickly be found and used based on tiles.
#	for h in used_highlights:
#		var hlayer = h.get_parent()
#		var pos    = hlayer.world_to_map(h.position)
#		pos = _rotate_coords(pos, direction)
#		h.position = hlayer.map_to_world(pos)

	camera.position = _rotate_position(camera.position, direction)
	
	_add_walkable_tiles()
	_connect_walkable_tiles()
	
	print("Orientation is ", orientation, " Direction was ", direction)
	print("--ROTATE-- ", direction,  " took ", OS.get_system_time_msecs() - time, " ms to run")
	print(linebreak)

#================================== SIGNALS ===================================#
#==============================================================================#

func _on_Rotate_Right_pressed():
	_rotate_map("right")
	return
func _on_Rotate_Left_pressed():
	_rotate_map("left")
	return

func _find_moverange():
	var time = OS.get_system_time_msecs()
	var array1 = []
	var array2 = []
	var indexes = [selecttileindex]
	var move_range = 500


	while move_range >= 0:
		if indexes == []:
			break
		for i in indexes:
			for ii in astar.get_point_connections(i):
				if indexes.has(ii) or array1.has(ii):
					continue
				else:
					if array2.has(ii):
						continue
					else:
						array1.append(ii)
			if array2.has(i):
				continue
			array2.append(i)
		indexes = array1
		array1 = []
		move_range -= 1
	array2.remove(array2.find(selecttileindex))
	_clear_highlights()
	set_highlights(array2)

	print("_find_moverange ran in ", OS.get_system_time_msecs() -time, "ms.")
func _find_moverange_slow():
	if runningfunc != 0:
		return
	var time = OS.get_system_time_msecs()
	var origintiles = []
	var filledtiles = []
	var searchtiles = [selecttileindex]
	var move_range = 500
	runningfunc += 1
	
	ignoremouseclicks = true
	_clear_highlights()
		
	while move_range >= 0:
#If there are no tiles to search from, break loop
		if searchtiles == []:
			break
		for i in searchtiles:
			if filledtiles.has(i):
				continue
			for ii in astar.get_point_connections(i):
				if searchtiles.has(ii) or origintiles.has(ii) or filledtiles.has(ii):
					continue
				else:
					origintiles.append(ii)
			filledtiles.append(i)

		searchtiles = origintiles
		origintiles = []
		move_range -= 1
		for h in used_highlights:
			if h[0].modulate != Color8(0,0,255,255):
				h[0].modulate = Color8(0,0,255,255)
		set_highlights(searchtiles, Color8(0,255,0,255))
		timer.start()
		yield(timer,"timeout")
	ignoremouseclicks = false
	runningfunc -= 1
	print("_find_moverange_slow ran in ", OS.get_system_time_msecs() -time, "ms.")
	print("used highlights size = ", used_highlights.size())

func _on_Timer_timeout():
	pass # Replace with function body.

#============================== Math Operations ===============================#
#==============================================================================#

func _rotate_position(pos, dir):
	pos = layers_ascending[0].world_to_map(pos)
	var newpos = Vector2.ZERO
	
	if dir == "right":
		newpos.x = ((pos.y - map_center.y) * -1) + map_center.x
		newpos.y = (pos.x - map_center.x) + map_center.y
	elif dir == "left":
		newpos.x = (pos.y - map_center.y) + map_center.x
		newpos.y = ((pos.x - map_center.x) * -1) + map_center.y

	newpos = layers[0].map_to_world(newpos)
	return newpos
func _rotate_coords(vec, direction):
	var newpos = Vector2.ZERO
	if typeof(vec) == TYPE_VECTOR3:
		newpos = Vector3(0,0,vec.z)
	
	if direction == "right":
		newpos.x = ((vec.y - map_center.y) * -1) + map_center.x
		newpos.y = (vec.x - map_center.x) + map_center.y
	elif direction == "left":
		newpos.x = (vec.y - map_center.y) + map_center.x
		newpos.y = ((vec.x - map_center.x) * -1) + map_center.y
	return newpos

func _calculate_index(point):
	return int(point.x + (map_size.x * point.y) + (map_size.x * map_size.y * point.z))
func index_to_vector(index, vec2=false):
	var point = Vector3.ZERO
	
	point.z     = int(index / (map_size.x * map_size.y)) 
	index       = index - (point.z * map_size.x * map_size.y)
	if vec2 == true:
		point = Vector2.ZERO
	point.y     = int(index / map_size.x)
	point.x     = index - (point.y * map_size.x)
	return (point)


#=========================== TEMPORARY FUNCTIONS ==============================#
#==============================================================================#

func _on_HSlider_value_changed(value):
	get_node("../../Interactive HUD/RichTextLabel").bbcode_text =\
	str("[center]Speed = ", value, "[/center]")
	timer.wait_time = 1/value

#==============================================================================#
#==============================================================================#
"""
Notes for future me:


COORDS: Means tilemap coordinates, usually something like (5,7)
	Coords should never be negative, as the entire gamespace is positive intgers

POSITION: Means global coordinates, usually look like (-128, 33)
	Position x coordinates can be negative as the middle of the screen is x = 0

INDEX: this is the A* index value of a tile/position. This is the master
coordinate used in all other calculations, it is used to connect everything together
so please make sure to sure index values whenever possible and only convert to
other coordinates when absolutely necessary

This implementation of A* is quite different from my previous ones as this one
needed to be able to work with rotations as well, which was impossible on the
old system.

On this system the A* is only ever drawn once, when the map is loaded, 
when the map is rotated (And thus all the tilemap coordinates/indexes change)
A* uses the main dictionary to understand what the true index value is of the
point that's selected.

in essence A* never needs to change, instead we just convert the altered map
coordinates to their original value (Orientation 0)

"""
