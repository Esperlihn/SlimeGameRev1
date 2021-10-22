extends TileMap

onready var map_origin         = Vector2(get_used_rect().position.x, get_used_rect().position.y)
onready var map_size           = Vector2(get_used_rect().end.x, get_used_rect().end.y)
onready var map_center         = Vector2((map_size.x / 2) - 0.5, (map_size.y / 2) - 0.5)
onready var astar              = AStar.new()
onready var layers             = get_node("..").get_children()
onready var height_limit       = get_node("..").get_child_count() - 1
onready var entity_height      = 3# height_limit
onready var highlight          = preload("res://Scenes/Highlight Tile.tscn")
onready var camera             = get_node("../../Interactive HUD")


#============================DEBUG=============================================#
var linebreak = "\n==============================\n"
export var debug:bool
#==============================================================================#

var orientation                = 0
var rot_value                  = 0
var unwalkable_tiles           = []
var walkable_tiles             = []
var used_tiles                 = []
var buffer_array               = []
var highlights                 = []
var highlightcount             = 0
var swimmable_tiles            = [4, 5, 6, 7]
var bridgetiles                = [8, 9, 10, 11]
var layers_ascending           = layers
var index_max_value            = 0
const bridgetileoffset         = 4
var test_array                 = []
var highlight_path             = []
var junk

class MyCustomSorter:
	static func sort_nodes_ascending(a, b):
		a = int(a.name)
		b =int(b.name)
		if a < b:
			return true
		return false


func _ready():
	var time = OS.get_system_time_msecs()
	index_max_value = map_size.x * map_size.y * layers.size() -1
	layers_ascending = layers
	layers_ascending.sort_custom(MyCustomSorter, "sort_nodes_ascending")
	for l in layers:
		l.z_index = int(l.name)
	map_origin.x = clamp(map_origin.x, 0, 99999)
	map_origin.y = clamp(map_origin.y, 0, 99999)

	_get_used_tiles()
	_add_walkable_tiles()
	_connect_walkable_tiles()
	_spawn_highlights()

	print(\
	linebreak,\
	"Map origin: ",map_origin,\
	"\nMap edge: ",map_size,\
	"\nTotal Used tiles = ", used_tiles.size(), \
	"\nWalkable Tiles = ", walkable_tiles.size(), \
	"\nHighlight Tiles = ", highlightcount, \
	"\nSystem startup took ", OS.get_system_time_msecs() - time, " ms to start",\
	linebreak )

func _unhandled_input(event):
	if event.is_action_pressed("mouse_left_click"):
		_navigate_to_click_location()

#======================== ASTAR FUNCTIONS =====================================#

func _get_used_tiles():
	var time = OS.get_system_time_msecs()
	
	for l in layers:
		var z = int(l.name)
		for cell in l.get_used_cells():
			if cell.x < map_origin.x or cell.y < map_origin.y or \
			cell.x > map_size.x or cell.y > map_size.y:
				l.set_cellv(cell, -1)
				continue
			var point_index = _calculate_point_index(Vector3(cell.x, cell.y, z))
			var value = l.get_cellv(cell)
			used_tiles.append(Vector2(point_index, value))
	print("Used tiles ran in ", OS.get_system_time_msecs() - time, " ms")

func _add_walkable_tiles():
	var time         = OS.get_system_time_msecs()
	var points_array = []
	var layer_size   = map_size.x * map_size.y

	for t in used_tiles:
		if t.x > index_max_value:
			continue
		var index = t.x
		var value = int(t.y)
		var point = _point_index_to_vec3(index)
#==============================================================================#
		if unwalkable_tiles.has(index):
			continue
		if value != 0:
			if swimmable_tiles.has(value):
				continue
#if the tile above is occupied, tile is not walkable
		if _index_to_cell_value(index + layer_size) != -1:
			continue
#If the next tile imemdiately above that is occupied. Tile is Still not walkable.
		else:
			if _index_to_cell_value(index + (layer_size * 2)) != -1:
				continue
#==============================================================================#

		points_array.append(Vector2(index, value))
		astar.add_point(index, point, 1)
	points_array.sort()
	walkable_tiles = points_array

	print("add_walkable_tiles ran in ", OS.get_system_time_msecs() - time, " ms")
	return

func _connect_walkable_tiles():
	var time =  OS.get_system_time_msecs() 
	for point in walkable_tiles:
		var point_index = point.x
		point = _point_index_to_vec3(point_index)
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
			var point_relative_index = _calculate_point_index(point_relative)
			if not astar.has_point(point_relative_index):
				continue
#This last function here is because the first row of x values was looping around
#And connecting with the last row of x values. This function should stop
#That from happening on every layer.
#IT doesn't work after a rotation I don't know WHY
			if point_relative.x < map_size.x:
				if point_relative_index - point_index > map_size.x * 2:
					continue

			astar.connect_points(point_index, point_relative_index, true)
	print("connect_walkable_tiles ran in ", OS.get_system_time_msecs() - time, " ms")
	return

#=============================

func _spawn_highlights():
	var time = OS.get_system_time_msecs()
	var counter = used_tiles.size() * 1.25
	while highlightcount < counter:
		var r = highlight.instance()
		highlights.append(r)
		layers_ascending[0].add_child(r)
		r.position.y -= 32
		r.visible = false
		highlightcount += 1
	print("spawn_highlights ran in ", OS.get_system_time_msecs() - time, " ms")

func _clear_highlights():
	for h in highlights:
		h.visible = false
		h.z_index = 0
		h.position = Vector2(0, -32)

#=============================

func _set_single_tile(tile):
	var value = int(tile.y)
	var vec3  = _point_index_to_vec3(tile.x)
	var layer = layers[vec3.z]
	var vec2  = Vector2(vec3.x, vec3.y)
#	print("tile: ", tile, " Vector 3: ", vec3, " value: ", value)
	layer.set_cellv(vec2, value)
	return tile

func _set_tiles():
	var time = OS.get_system_time_msecs()
	for t in walkable_tiles:
		var index = t.x
		var value = t.y
		var point = _point_index_to_vec3(index)
		var layer = layers_ascending[point.z]
		point = Vector2(point.x, point.y)
		layer.set_cellv(point, value)
	print("_set_tiles ran in ", OS.get_system_time_msecs() - time, " ms")

func _set_highlights(tile_array):
	var time = OS.get_system_time_msecs()
	for w in tile_array:
		var pos = _point_index_to_vec3(w.x)
		var value = int(w.y)
		var layer = layers_ascending[pos.z]
		var layer_offset = layer.position.y
		var highlighter = highlights.pop_front()
		if pos.z > 0:
			layer_offset += 16
		if bridgetiles.has(value):
			layer_offset += 4
		pos = Vector2(pos.x, pos.y)

		highlighter.visible = true
		highlighter.position = layer.map_to_world(pos)
		highlighter.position.y += layer_offset
		highlighter.z_index = layer.z_index
		highlights.push_back(highlighter)
	print("_set_highlights ran in ", OS.get_system_time_msecs() - time, " ms")

#=============================

func _rotate(dir):
	var totaltime = OS.get_system_time_msecs()
	var time = OS.get_system_time_msecs()
	print(linebreak, "\n--ROTATE--")
	buffer_array = []

	if dir == "right":
		orientation = wrapi(orientation + 90, 0, 360)
	if dir == "left":
		orientation = wrapi(orientation - 90, 0, 360)

	for l in layers:
		l.clear()
	_clear_highlights()
	astar.clear()
	print("clearing map and highlights took ", OS.get_system_time_msecs() - time, " ms to run")

	time = OS.get_system_time_msecs()
	for tile in used_tiles:
		tile = _rotate_index_90(tile, dir)
		buffer_array.append(tile)
		_set_single_tile(tile)
	used_tiles = buffer_array
	buffer_array = []
	for tile in highlight_path:
		tile = _rotate_index_90(tile, dir)
		buffer_array.append(tile)
		_set_single_tile(tile)
	highlight_path = buffer_array
	buffer_array = []
	print("converting coordinates took ", OS.get_system_time_msecs() - time, " ms to run")

	_add_walkable_tiles()
	_connect_walkable_tiles()
	_set_highlights(highlight_path)
	camera.smoothing_enabled = false
	camera.position = _rotate_camera_90(camera.position, dir)
	
	print("--ROTATE-- ", dir,  " took ", OS.get_system_time_msecs() - totaltime, " ms to run")
	print("Orientation is ", orientation, " Direction was ", dir)
	print(linebreak)
	return

func _navigate_to_click_location():
	var time = OS.get_system_time_msecs()
	var boo = get_global_mouse_position()
	var layer
	var finalpos
	var value
	var index

	_clear_highlights()
	highlight_path = []
	for l in layers:
		l = get_node(str("../", l.name))
		var mouse = boo
		if l.name != "0":
			mouse.y -= l.position.y + 16
		var pos = l.world_to_map(mouse)
		var v = l.get_cellv(pos)
		if v == -1:
			continue
		else:
			layer = l.name
			finalpos = pos
			value = v
	if !finalpos or finalpos.x < 0 or finalpos.y < 0:
		return
	index = _calculate_point_index(Vector3(finalpos.x, finalpos.y, int(layer)))
	test_array = astar.get_id_path(1, index)
	for t in test_array:
		highlight_path.append(Vector2(t, _index_to_cell_value(t)))
	_set_highlights(highlight_path)
	print("Layer ", layer, "\ncell: ", finalpos, "\nValue: ", value)
	print("click took ", OS.get_system_time_msecs() - time, " ms to run")
#==============================================================================#
#========================== SIGNALS ===========================================#

func _on_Rotate_Right_pressed():
	_rotate("right")
	return
func _on_Rotate_Left_pressed():
	_rotate("left")
	return

#==============================================================================#
#====================== Math Operations ======================================#

func _rotate_index_90(tile, dir):
	var newcoord  = Vector3.ZERO
	var new_index = 0
	
	var index     = tile.x
	var value     = tile.y
	var coord     = _point_index_to_vec3(index)
	var pos       = Vector2(coord.x, coord.y)

	if dir == "right":
		pos = pos - map_center
		pos = Vector2(-pos.y, pos.x)
		pos = pos + map_center
		newcoord = Vector3(pos.x, pos.y, coord.z)
	elif dir == "left":
		newcoord.x = (coord.y - map_center.y) + map_center.x
		newcoord.y = ((coord.x - map_center.x) * -1) + map_center.y
		newcoord.z = coord.z
	else:
		assert("Oh fuck")
	new_index = _calculate_point_index(newcoord)
	
	return Vector2(new_index, value)
func _rotate_camera_90(pos, dir):
	pos = layers_ascending[0].world_to_map(camera.position)
	var newpos = Vector2.ZERO
	
	if dir == "right":
		newpos.x = ((pos.y - map_center.y) * -1) + map_center.x
		newpos.y = (pos.x - map_center.x) + map_center.y
	elif dir == "left":
		newpos.x = (pos.y - map_center.y) + map_center.x
		newpos.y = ((pos.x - map_center.x) * -1) + map_center.y

	newpos = layers_ascending[0].map_to_world(newpos)
	newpos.y += 16
	return newpos

func _calculate_point_index(point):
	return point.x + (map_size.x * point.y) + (map_size.x * map_size.y * point.z)
func _point_index_to_vec3(point_index):
	var point = Vector3.ZERO
	point.z     = int(point_index / (map_size.x * map_size.y)) 
	point_index = point_index - (point.z * map_size.x * map_size.y)
	point.y     = int(point_index / map_size.x)
	point.x     = point_index - (point.y * map_size.x)
	return (point)
func _point_index_to_vec2(point_index):
	var point = Vector2.ZERO
	point_index = point_index - (point.z * map_size.x * map_size.y)
	point.y     = int(point_index / map_size.x)
	point.x     = point_index - (point.y * map_size.x)
	return(point)

func _index_to_cell_value(index):
	if int(index) > int(index_max_value):
		return -1
	var point = _point_index_to_vec3(index)
	var layer = layers[point.z]
	return layer.get_cellv(Vector2(point.x, point.y))

#==============================================================================#
#==============================================================================#
