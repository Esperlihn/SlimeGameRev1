"""
This file is part of:
Lihnpixel Games
https://lihnpixel.ca
***********************
Copyright (c) 2020 -2021 Sukh Atwal


IMPORTANT NOTE:
	MAPS CAN ONLY BE 2x2, 4x4, 8x8, 16x16, 32x32, and 64x64 grids!
	MUST have 9(0,1,2,3,4,5,6,7,8) tilemaps of height!!!
"""


extends Node2D

var level_name                      = "Test_Level_32x"
onready var image                   = Image.new()
onready var layers_descending:Array = []
onready var highlight               = preload("res://Scenes/Objects/Highlight Tile.tscn")
onready var tile_select_highlight   = preload("res://Scenes/Objects/Select_highlight.tscn")
onready var timer                   = get_node("../Timer")
onready var speed_slider            = get_node("../HUD/V/H/V/H/V/HSlider")
onready var camera                  = get_node("../Interactive HUD")

export var load_external_level:bool = false

enum I {
	CELLVALUE, #     1
	LAYER,     #     2
	COORD, #         3
	COORD90, #       4
	COORD180, #      5
	COORD270, #      6
	POINT,#          7
	POINT90,#        8
	POINT180,#       9
	POINT270,#       10
	POSITION,#       11
	POSITION90,#     12
	POSITION180,#    13
	POSITION270,#    14
	INDEX, #         15
	INDEX90, #       16
	INDEX180, #      17
	INDEX270, #      18
	HIGHLIGHT, #     19
	WALKABLE, #      20
	SWIMMABLE, #     21
	HEIGHT,    #     22
	ENTITY,#         23
	TERRAINEFFECTS,# 24
	}

var colour_palette     = [
	Color(0,0,0,0),             # Empty Tile
	Color(0,0.5,0.25),          # Grass Tile
	Color(0,0.25,0.75),         # Water Tile
	Color(1,0.75,0),            # Sand Brick Tile
	Color(0.5,0.25,0),          # Wood Bridge Tall Tile
	Color(0.5,0.25,0,0.75),     # Wood Bridge Short Tile
	Color(1,1,1,0),             # Treasure Tile
	Color(0,0.25,0.75,0.75),    # Water Tile Tall
	]
var png_save_path      = str("user://", level_name, ".png")
var atlas:Dictionary   = {}
var layers:Array       = []
var astar              = AStar.new()

var map_size:Vector2   = Vector2.ZERO
var map_origin:Vector2 = Vector2.ZERO
var map_center:Vector2 = Vector2.ZERO

var max_index:int      = 0
var layer_size:int     = 0
var active_tile:int    = 0

var used_tiles         = []
var walkable_tiles     = []
var swimmable_tiles    = [1]
var walkable_height    = 2

var highlight_array    = []
var tile_select:Object
var tileoffsets        = [0, 8, 0, 4, -4, 0]
var orientation        = 0

var linebreak          = "\n==============================\n"
var ignoremouse        = false
var seconds            = 0

#==============================================================================#
#========================== STARTUP ONLY FUNCTIONS ============================#
#==============================================================================#


func _ready() -> void:
	var time = OS.get_system_time_msecs()
	print(linebreak)

	_organise_tilemap_and_set_values()
	if load_external_level == true:
		load_map_from_image()
	_populate_atlas()
	_get_used_tiles()
	_add_walkable_tiles()
	_connect_walkable_tiles()
	_spawn_highlights()
	
	print(Log.logger(str(\
	linebreak,\
	"\nMap origin: ",map_origin,\
	"\nMap edge: ",map_size,\
	"\nTotal Used tiles = ", used_tiles.size(), \
	"\nWalkable Tiles = ", walkable_tiles.size(), \
	"\nTotal potential index points = ", atlas.size(),\
	"\n\n==============================",\
	"\nSystem startup took ", OS.get_system_time_msecs() - time, " ms",\
	linebreak )))
	if load_external_level == false:
		save_map_as_image()

func _populate_atlas() -> void:
	var time = OS.get_system_time_msecs()

	var cell_value:int
	var layer
	
	#TILEMAP COORDINATES
	var coord:Vector2
	var coord90:Vector2
	var coord180:Vector2
	var coord270:Vector2
	
	#ASTAR COORDS
	var point:Vector3
	var point90:Vector3
	var point180:Vector3
	var point270:Vector3
	
	#GLOBAL POSITIONS
	var position:Vector2
	var position90:Vector2
	var position180:Vector2
	var position270:Vector2
	
	#ASTAR INDEX VALUES
	var index:int
	var index90:int
	var index180:int
	var index270:int
	
	#OTHER VALUES
	var highlight_obj
	var walkable:bool
	var swimmable:bool
	var height:int
# warning-ignore:unused_variable
	var entity:Object
# warning-ignore:unused_variable
	var terraineffects

	for x in range(0, map_size.x):
		for y in range(0, map_size.y):
			for z in range(0, layers.size()):
				cell_value    = -1
				layer         = layers[z]
				coord         = Vector2(x, y)
				coord90       = _rotate_coords(coord, "right")
				coord180      = _rotate_coords(coord90, "right")
				coord270      = _rotate_coords(coord180, "right")
				point         = Vector3(x, y, z)
				point90       = Vector3(coord90.x, coord90.y, z)
				point180      = Vector3(coord180.x, coord180.y, z)
				point270      = Vector3(coord270.x, coord270.y, z)
				position      = layer.map_to_world(coord)
				position90    = layer.map_to_world(coord90)
				position180   = layer.map_to_world(coord180)
				position270   = layer.map_to_world(coord270)
				index         = _calculate_index(point)
				index90       = _calculate_index(point90)
				index180      = _calculate_index(point180)
				index270      = _calculate_index(point270)
				highlight_obj = null
				walkable      = false
				swimmable     = false
				height        = 0
				entity        = null
				terraineffects= null
				atlas[index]  = \
				[
				cell_value, layer,
				coord, coord90, coord180, coord270,
				point, point90, point180, point270,
				position, position90, position180, position270,
				index, index90, index180, index270,
				highlight_obj,
				walkable, swimmable, height
				]
	print(Log.logger(str("populate_atlas ran in ", OS.get_system_time_msecs() - time, " ms")))
func _organise_tilemap_and_set_values() -> void:
	for i in self.get_children():
		if i.name == "9":
			continue
	#Creating the Layer arrays to be iterated through
		layers_descending.push_back(i)
		layers.push_front(i)
		#Setting each layer's Z index to their corresponding height
		i.z_index = int(i.name)
		
	#Removing any cells in negative coordinates
		for cell in i.get_used_cells():
			if cell.x < 0 or cell.y < 0:
				i.set_cellv(cell, -1)

	#Finding the outer limits of the map and making sure the map is a square.
	#The rotate function absolutely requires the map to be square to work correctly.
		if load_external_level == false:
			if i.get_used_rect().end.x > map_size.x:
				map_size.x = i.get_used_rect().end.x
				if map_size.x > map_size.y:
					map_size.y = map_size.x
			if i.get_used_rect().end.y > map_size.y:
				map_size.y = i.get_used_rect().end.y
				if map_size.y > map_size.x:
					map_size.x = map_size.y
	if load_external_level == false:
		#Assiging a few map variable that are used throughout the game.
		map_center = Vector2((map_size.x / 2) - 0.5, (map_size.y / 2) - 0.5)
		max_index = int(map_size.x * map_size.y) * (self.get_child_count() - 1) - 1
		#I really want to rename this variable to something more self-evident. Need ideas.
		layer_size = int(map_size.x * map_size.y)
	timer.wait_time = (speed_slider.max_value - speed_slider.value) / 100.0
	speed_slider.get_parent().visible = false
func _get_used_tiles() -> void:
	var time = OS.get_system_time_msecs()
	
	for l in layers:
		var z = int(l.name)
		for cell in l.get_used_cells():
			if cell.x < map_origin.x or cell.y < map_origin.y or \
			cell.x > map_size.x or cell.y > map_size.y:
				l.set_cellv(cell, -1)
				continue
			var index = _calculate_index(Vector3(cell.x, cell.y, z))
			var value = l.get_cellv(cell)
			used_tiles.append(int(index))
			atlas[index][I.CELLVALUE] = value
			atlas[index][I.POSITION].y += tileoffsets[value]
			atlas[index][I.POSITION90].y += tileoffsets[value]
			atlas[index][I.POSITION180].y += tileoffsets[value]
			atlas[index][I.POSITION270].y += tileoffsets[value]
	print(Log.logger(str("Used tiles ran in ", OS.get_system_time_msecs() - time, " ms")))
func _add_walkable_tiles() -> void:
	var time         = OS.get_system_time_msecs()
	var index_array = []
	var height       = layers.size() + 4

	for index_tile in used_tiles:
		if index_tile > max_index:
			continue
		var value = atlas[index_tile][I.CELLVALUE]
		var point = atlas[index_tile][I.POINT]
		var new_index = index_tile
	#==========================================================================#
		if value != 0:
			if swimmable_tiles.has(value):
				continue

		var tallness = height - point.z
		var h = 0
		while h <= tallness:
			new_index = new_index + layer_size
		#If the new height is above height limit, break loop.
			if new_index > max_index:
				atlas[index_tile][I.HEIGHT] = tallness
				break
		#If the above tile is occupied, break loop
			if atlas[new_index][I.CELLVALUE] != -1:
				atlas[index_tile][I.HEIGHT] = h
				break
			else:
				h += 1
				continue
		#Excluding all tiles that don't have enough space above for
		#any entities to stand on them
		if atlas[index_tile][I.HEIGHT] < walkable_height:
			continue
	#==========================================================================#
		atlas[index_tile][I.WALKABLE] = true
		index_array.append(index_tile)
		astar.add_point(index_tile, point, 1)
	walkable_tiles = index_array

	print(Log.logger(str("add_walkable_tiles ran in ", OS.get_system_time_msecs() - time, " ms")))
func _connect_walkable_tiles() -> void:
	var time =  OS.get_system_time_msecs() 
	for index in walkable_tiles:
		var point = atlas[index][I.POINT]
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
			if not _remove_wraparound_tiles(point, index, point_relative, point_relative_index):
				continue
			astar.connect_points(index, point_relative_index, true)
	
	print(Log.logger(str("connect_walkable_tiles ran in ", OS.get_system_time_msecs() - time, " ms")))
func _remove_wraparound_tiles(point, index, point_relative, point_relative_index):
	
#If the point we're finding connections for is along the map's y edge
	if point.y == 0 or point.y == map_size.y - 1:
		#If the index we're checking is more than one column width away
		if abs(point_relative_index - index) > map_size.x:
			return null

#If the point we're finding connections for is along the map's x edge
	if point.x == 0 or point.x == map_size.x - 1:
		#I actually don't remember how this one works.
		if abs(point_relative_index - index) == 1:
			return null

#if the point we're checking is negative or larger than the map bounds
	if point_relative.y < 0 or point_relative.y > map_size.y - 1\
	or point_relative.x < 0 or point_relative.x > map_size.x - 1:
		return null
	return true
func _spawn_highlights() -> void:
	var time = OS.get_system_time_msecs()
	for tile in walkable_tiles:
		var r = highlight.instance()
		var layer = atlas[tile][I.LAYER]
		atlas[tile][I.HIGHLIGHT] = r
		highlight_array.append(r)

		layer.add_child(r)
		r.position = atlas[tile][I.POSITION]
		if int(layer.name) > 0:
			r.position.y += 16
	print(Log.logger(str("spawn_highlights ran in ", OS.get_system_time_msecs() - time, " ms")))
func _rotate_coords(vec, direction):# -> Vector2 or Vector3
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


#=============================== Input Control ================================#
#==============================================================================#


func _unhandled_input(event) -> void:
	if event.is_action_pressed("mouse_left_click"):
		if ignoremouse == true:
			return

		_clear_highlights()
		var index = [identify_tile(get_global_mouse_position())]
		if index[0] == -1:
			print("Please select a valid tile within bounds")
			return
		if walkable_tiles.has(index[0]):
			print("valid! ", index[0])
			print("Height:", atlas[index[0]][I.HEIGHT])
		else:
			print("Not Valid! ", index[0])
			print("Height:", atlas[index[0]][I.HEIGHT])
			return
		active_tile = index[0]
		spawn_object_at_index(index[0], tile_select_highlight)


	if event.is_action_pressed("ui_f11"):
		OS.window_fullscreen = !OS.window_fullscreen

func identify_tile(pos) -> int:
	var index
	var newpos
	
	for l in layers_descending:
		var z = int(l.name)
		newpos = pos
		if z > 0:
			newpos.y -= l.position.y + 17
		var coord = l.world_to_map(newpos)
		var value = l.get_cellv(coord)
		if value != -1:
			index = _calculate_index(Vector3(coord.x, coord.y, z))
			break

	if index == null:
		return -1

	match orientation: #degrees of rotation required to get back to original position.
		0:   index = atlas[index][I.INDEX]
		90:  index = atlas[index][I.INDEX270]
		180: index = atlas[index][I.INDEX180]
		270: index = atlas[index][I.INDEX90]

	return index


#============================= REGULAR FUNCTIONS ==============================#
#==============================================================================#


func set_highlights(index, color = Color.green) -> void:
	for i in index:
		var highlight_tile = atlas[i][I.HIGHLIGHT]
		highlight_tile.visible = true
		highlight_tile.modulate = color

func _clear_highlights() -> void:
	for i in highlight_array:
		i.visible = false
		i.modulate = Color.white
	if tile_select != null:
		tile_select.queue_free()
		tile_select = null
func _clear_map() -> void:
	for l in layers:
		l.clear()
	_clear_highlights()
	astar.clear()

func _rotate_map(direction) -> void:
	var time = OS.get_system_time_msecs()
	var COORD:int = I.COORD
	var POSITION:int = I.POSITION
	var LAYER:int = I.LAYER
	var CELLVALUE:int = I.CELLVALUE
	var HIGHLIGHT:int = I.HIGHLIGHT
	var INDEX:int = I.INDEX
	var rot_center

	#setting new orientation
	if direction == "right":
		orientation  = wrapi(orientation + 90, 0, 360)
	if direction == "left":
		orientation  = wrapi(orientation - 90, 0, 360)

	#adjusting coordinates to orientation
	COORD = COORD + (orientation / 90)
	POSITION = POSITION + (orientation / 90)
	INDEX = INDEX + (orientation / 90)

	#Clear all Tiles
	for l in layers:
		l.clear()

	#Rotating all nonemptytiles
	for index in used_tiles:
		var layer = atlas[index][LAYER]
		var cell_value = atlas[index][CELLVALUE]
		var new_coords = atlas[index][COORD]
		layer.set_cellv(new_coords, cell_value)

	#Rotating all highlights
	for index in walkable_tiles:
		var highlight_tile = atlas[index][HIGHLIGHT]
		var new_position = atlas[index][POSITION]

		highlight_tile.position = new_position
		if index > layer_size:
			highlight_tile.position.y += 17
	
	#Rotating selection tile
	if tile_select != null:
		var layer = tile_select.get_parent()
		var newpos
		var offset = Vector2.ZERO

		if int(layer.name) > 0:
			offset.y += 17

		match orientation:
		#I have no fucking clue how or why this works. But it does.
			0:   newpos = atlas[active_tile][I.POSITION] + offset
			90:  newpos = atlas[active_tile][I.POSITION90] + offset
			180: newpos = atlas[active_tile][I.POSITION180] + offset
			270: newpos = atlas[active_tile][I.POSITION270] + offset
		tile_select.position = newpos

	#No clue why this works either.
		if direction == "right":
			rot_center = atlas[active_tile][INDEX]
			rot_center = atlas[rot_center][I.POSITION270]
		if direction == "left":
			rot_center = atlas[active_tile][INDEX]
			rot_center = atlas[rot_center][I.POSITION90]

	#Rotate around selected tile, or tile at center of screen if no tile is
	#currently selected.
	if rot_center != null:
		camera.position = _rotate_position(rot_center, direction)
	else:
		camera.position = _rotate_position(camera.position, direction)
	
	print(Log.logger(str("Orientation is ", orientation, " Direction was ", direction)))
	print(Log.logger(str("--ROTATE-- ", direction,  " took ", OS.get_system_time_msecs() - time, " ms to run")))


#============================== ASTAR FUNCTIONS ===============================#
#==============================================================================#


func find_moverange(move_range = 5) -> void:
	var time = OS.get_system_time_msecs()
	var origintiles = []
	var filledtiles = []
	var searchtiles = [active_tile]

	#Checking if the origin tile is a valid tile that entities can stand on
	if !walkable_tiles.has(active_tile):
		Log.logger(printerr("Selected tile is not a valid origin point"))
		return
	
	ignoremouse = true
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

		move_range -= 1
		set_highlights(searchtiles, Color.blue)
		set_highlights(origintiles, Color.green)
		searchtiles = origintiles
		origintiles = []
		timer.start()
		yield(timer,"timeout")
	ignoremouse = false
	print(Log.logger(str("_find_moverange_slow ran in ", OS.get_system_time_msecs() -time, "ms.")))

func add_astar_point(index) -> void:
#Tested this function, it does not cause wraparound when used on map edges
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
func remove_astar_point(index) -> void:
	astar.remove_point(index)

#================================== SIGNALS ===================================#
#==============================================================================#


func _on_Timer_timeout() -> void:
	pass # Replace with function body.

func _on_HSlider_value_changed(value) -> void:
	get_node("../HUD/VBoxContainer/HBoxContainer/VBoxContainer/RichTextLabel").bbcode_text =\
	str("[center]Speed = ", value / 2.5, "[/center]")
	if value >= speed_slider.max_value:
		value -= 1
	timer.wait_time = (speed_slider.max_value - value) / 100.0
	print(Log.logger(str(timer.wait_time)))

func _on_Rotate_Right_pressed() -> void:
	_rotate_map("right")
	return
func _on_Rotate_Left_pressed() -> void:
	_rotate_map("left")
	return


#============================== Math Operations ===============================#
#==============================================================================#


func _calculate_index(point) -> int:
	return int(point.x + (map_size.x * point.y) + (map_size.x * map_size.y * point.z))

func index_to_cellv(index) -> int:
	var vec = index_to_vector(index)
	var layer = layers[vec.z]
	var cellv = layer.get_cellv(Vector2(vec.x, vec.y))
	return cellv
	
func index_to_vector(index, vec2=false):# -> Vector2 or Vector3
	var point = Vector3.ZERO
	
	point.z     = int(index / (map_size.x * map_size.y)) 
	index       = index - (point.z * map_size.x * map_size.y)
	if vec2 == true:
		point = Vector2.ZERO
	point.y     = int(index / map_size.x)
	point.x     = index - (point.y * map_size.x)
	return (point)

func _rotate_position(pos, dir) -> Vector2:
	pos = layers[0].world_to_map(pos)
	var newpos = Vector2.ZERO
	
	if dir == "right":
		newpos.x = ((pos.y - map_center.y) * -1) + map_center.x
		newpos.y = (pos.x - map_center.x) + map_center.y
	else:
		newpos.x = (pos.y - map_center.y) + map_center.x
		newpos.y = ((pos.x - map_center.x) * -1) + map_center.y

	newpos = layers[0].map_to_world(newpos)
	return newpos

func spawn_object_at_index(index, object) -> void:
	var r = object.instance()
	var layer = atlas[index][I.LAYER]
	var POSITION = I.POSITION
	layer.add_child(r)
	r.z_index = layer.z_index
	
	#Adjusting for orientation
	POSITION = POSITION + (orientation / 90)

	r.position = atlas[index][POSITION]

	if int(layer.name) > 0:
		r.position.y += 17
	
	match object:
		tile_select_highlight:
			tile_select = r


#============================ Resource Management =============================#
#==============================================================================#


func save_map_as_text_file() -> void:
	var array = []
	var file
	var string = ""
	for i in layers:
		for y in range(map_size.y):
			for x in range(map_size.x):
				array.append(i.get_cellv(Vector2(x, y)) +1)
	for i in array:
		string = str(string, i)
	file = File.new()
	file.open("res://array_new.txt", File.WRITE)
	file.store_line(string)
	file.store_line(str(map_size))
	file.store_line(str(layers.size()))
	file.close()
func load_map_from_text_file() -> void:
	var file
	var data
	var array = []

	file = File.new()
	file.open("res://array.txt", File.READ)
	data = file.get_line()
	map_size = Functions.str_to_vec2(file.get_line())
	file.close()

	for layer in layers:
		layer.clear()

	for i in data:
		i = int(i)
		array.append(i-1)
	data = array

	draw_map_from_array(data)

func save_map_as_image() -> void:
	var tile_value_array = []
	var image_width = (map_size.x * 3)
	var image_height = (map_size.y * 3)
	var start_position = Vector2((image_width/2), image_height/2)
	var current_position = start_position
	var _counter = 0
	var increment = false
	var increment_value = 1
	var move_value = 1
	var move_dir = "Up"
	var direction = {
		"Right": Vector2(1, 0), "Left": Vector2(-1, 0),
		"Up": Vector2(0, -1), "Down": Vector2(0, 1), "None": Vector2.ZERO
	}
	image.create(image_width, image_height, false, Image.FORMAT_RGBA8)
	for i in layers:
		if i.name == "9":
			break
		for y in range(map_size.y):
			for x in range(map_size.x):
				tile_value_array.append(i.get_cellv(Vector2(x, y))+1)
	image.lock()
	for value in tile_value_array:
		image.set_pixelv(current_position, colour_palette[value])
		
		if move_value > 0:
			current_position += direction[move_dir]
			move_value -= 1

		else:
			if increment == true:
				increment_value += 1
			increment = !increment
			
			match move_dir:
				"Right":
					move_dir = "Up"
					current_position += direction[move_dir]
				"Up":
					move_dir = "Left"
					current_position += direction[move_dir]
				"Left":
					move_dir = "Down"
					current_position += direction[move_dir]
				"Down":
					move_dir = "Right"
					current_position += direction[move_dir]
			
			move_value = increment_value - 1
		_counter += 1
	image.unlock()
	image.save_png(png_save_path)
	image.resize((image_width)*8, (image_height)*8, 0)
	image.save_png(str("user://", level_name, "-4.png"))
func load_map_from_image() -> void:
	var time = OS.get_system_time_msecs()
	var _counter = 0
	image.load(png_save_path)
	var image_width = image.get_width()
	var image_height = image.get_height()
	var width = image_width / 3
	var height = image_height / 3
	var start_position = Vector2(image_width/2, image_height/2)
	var current_position = start_position
	var tile_value_array = []
	var increment = false
	var increment_value = 1
	var move_value = 1
	var move_dir = "Up"
	var direction = {
		"Right": Vector2(1, 0), "Left": Vector2(-1, 0),
		"Up": Vector2(0, -1), "Down": Vector2(0, 1), "None": Vector2.ZERO
	}

	map_size = Vector2(width, height)
	map_center = Vector2(width/2, height/2)
	layer_size = width * height
	max_index = layer_size * layers.size() - 1

	image.lock()
	for _i in range(0, image_width*image_height):
		tile_value_array.push_back(get_pixel_value(image, current_position))
	
		if move_value > 0:
			current_position += direction[move_dir]
			move_value -= 1

		else:
			if increment == true:
				increment_value += 1
			increment = !increment

			match move_dir:
				"Right":
					move_dir = "Up"
					current_position += direction[move_dir]
				"Up":
					move_dir = "Left"
					current_position += direction[move_dir]
				"Left":
					move_dir = "Down"
					current_position += direction[move_dir]
				"Down":
					move_dir = "Right"
					current_position += direction[move_dir]
			move_value = increment_value - 1
		_counter += 1

	image.unlock()
	for i in layers:
		i.clear()
	draw_map_from_array(tile_value_array)
	print("load_map_from_image took ", OS.get_system_time_msecs() - time, \
	"ms to run")

func get_pixel_value(_image, position_in_image):
	var value = _image.get_pixelv(position_in_image)
	value.r = stepify(value.r, 0.05)
	value.g = stepify(value.g, 0.05)
	value.b = stepify(value.b, 0.05)
	value.a = stepify(value.a, 0.05)
	var new_value = colour_palette.find(value)
	if new_value != -1:
		return new_value
	else:
		printerr("Colour did not match any known tile value! ", value)
func draw_map_from_array(tile_value_array):
	var index = 0
	for value in tile_value_array:
		var vec3 = index_to_vector(index)
		var layer = layers[vec3.z]
		var vec2 = Vector2(vec3.x, vec3.y)
		if index == 1024:
			print(value)
		value = value - 1
		layer.set_cellv(vec2, value)
		index += 1


#========================== Misc. & Debug Functions ===========================#
#==============================================================================#


func print_atlas_index_keys(index):
	var keys = \
		[
		"CELLVALUE","LAYER","COORD","COORD90","COORD180","COORD270","POINT","POINT90",
		"POINT180","POINT270","POSITION","POSITION90","POSITION180","POSITION270",
		"INDEX","INDEX90","INDEX180","INDEX270","HIGHLIGHT","WALKABLE","SWIMMABLE",
		"HEIGHT","ENTITY","TERRAINEFFECTS"
		]
	var count = 0
	for i in atlas[index]:
		print(keys[count], ":", i)
		count += 1

func earthquake():
#	var shakes = 20
#	var flip = false
	var map = get_node("0")
	map.cell_half_offset == map.HALF_OFFSET_X
	var new_map = map.duplicate()
	self.remove_child(map)
	self.add_child(new_map)
	print(new_map.name)
	print("RUN")
#	if shakes > 0:
#		for tilemap in layers:
#			if flip == false:
#				print("Is this running?")
#				tilemap.cell_half_offset == tilemap.HALF_OFFSET_X
#				tilemap.update()
#			else:
#				tilemap.cell_half_offset == tilemap.HALF_OFFSET_NEGATIVE_X
#				tilemap.update()
#		shakes -= 1
#		flip = !flip
#		yield(timer, "timeout")
#		print(shakes)

	for tilemap in layers:
		tilemap.cell_half_offset == tilemap.HALF_OFFSET_DISABLED
	

#==============================================================================#
#==============================================================================#
#==============================================================================#
"""
Notes for future me:

COORDS: 
	Vector2 Tilemap Coordinates
	Coords should never be negative, as the entire gamespace only works with positive intgers
POSITION:
	Vector2 Global Coordinates
	Means global coordinates, usually look like (-128, 33)
	Position x coordinates can be negative as the middle of the screen is x = 0
POINT:
	Vector3 Astar Coordinates
	there are the dimensional coordinates within the astar grid.
	Astar coordinates also cannot be negative in this implementation.
INDEX: 
	this is the A* index value of a tile/position. This is the master
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
ATLAS: 
	is the master dictionary that stores all the information about the map in
	one location. Whenever anything on the map changes, that change MUST be reflected
	in the Atlas as well, as everything in the game refers to the atlas for information.

"""

