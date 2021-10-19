extends TileMap

onready var map_origin         = Vector2(get_used_rect().position.x, get_used_rect().position.y)
onready var map_size           = Vector2(get_used_rect().end.x, get_used_rect().end.y)
onready var map_center         = Vector2((map_size.x / 2) - 0.5, (map_size.y / 2) - 0.5)
onready var astar              = AStar.new()
onready var layers             = get_node("..").get_children()
onready var height_limit       = get_node("..").get_child_count() - 1
onready var entity_height      = 1# height_limit
onready var highlight          = preload("res://Highlight Tile.tscn")


#============================DEBUG=============================================#
var linebreak = "\n==============================\n"
export var debug:bool
#==============================================================================#

var orientation                = 0
var unwalkable_tiles           = []
var walkable_tiles             = []
var used_tiles                 = []
var buffer_array               = []
var highlights                 = []
var highlightcount             = 0
var swimmable_tiles            = [4, 5, 6, 7]
var bridgetiles                = [8, 9, 10, 11]
const bridgetileoffset           = 4


func _ready():
	get_node("../4").clear()
	for l in layers:
		l.z_index = int(l.name)
	map_origin.x = clamp(map_origin.x, 0, 99999)
	map_origin.y = clamp(map_origin.y, 0, 99999)
	print(linebreak, "Map origin: ",map_origin,"\nMap edge: ",map_size,linebreak)
	_get_used_tiles()
	add_walkable_tiles()
	connect_walkable_tiles()
	spawn_highlights(walkable_tiles)

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
			var point_index = calculate_point_index(Vector3(cell.x, cell.y, z))
			var value = l.get_cellv(cell)
			used_tiles.append(Vector2(point_index, value))
	print("Used tiles ran in ", OS.get_system_time_msecs() - time, " ms")

func add_walkable_tiles():
	var time         = OS.get_system_time_msecs()
	var points_array = []
	var layer_size   = map_size.x * map_size.y

	for t in used_tiles:
		var index = t.x
		var value = int(t.y)
		var point = point_index_to_vec3(index)
#==============================================================================#
		if unwalkable_tiles.has(index):
			continue
		if value != 0:
			if swimmable_tiles.has(value):
				continue
#if the tile above is occupied, tile is not walkable
		if Index_to_cell_value(index + layer_size) != -1:
			continue
#If the next tile imemdiately above that is occupied. Tile is Still not walkable.
		else:
			if Index_to_cell_value(index + (layer_size * 2)) != -1:
				print(index)
				continue
#==============================================================================#

		points_array.append(Vector2(index, value))
		astar.add_point(index, point, 1)
	walkable_tiles = points_array

	print("add_walkable_tiles ran in ", OS.get_system_time_msecs() - time, " ms")
	return

func connect_walkable_tiles():
	var time =  OS.get_system_time_msecs() 
	for point in walkable_tiles:
		var point_index = point.x
		point = point_index_to_vec3(point_index)
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
			var point_relative_index = calculate_point_index(point_relative)
			if not astar.has_point(point_relative_index):
				continue
			astar.connect_points(point_index, point_relative_index, false)
	print("connect_walkable_tiles ran in ", OS.get_system_time_msecs() - time, " ms")
	return

func spawn_highlights(array):
	var time = OS.get_system_time_msecs()
	for p in array:
		var point       = point_index_to_vec3(p.x)
		var value       = int(p.y)
		var r           = highlight.instance()
		var point_world = map_to_world(Vector2(point.x, point.y))
		var layer       = get_node(str("../", point.z))

		layer.add_child(r)
		r.position.x = point_world.x
		if point.z == 0:
			r.position.y = point_world.y + 16
			if bridgetiles.has(value):
				r.position.y += bridgetileoffset
		else:
			r.position.y = point_world.y + 33
			if bridgetiles.has(value):
				r.position.y += bridgetileoffset
	print("spawn_highlights ran in ", OS.get_system_time_msecs() - time, " ms")

func destroy_highlights(layer):
	var test = layer.get_children()
	for child in test:
		child.queue_free()

func rotate(dir):
	var time = OS.get_system_time_msecs()
	buffer_array = []
	var rot

	if dir == "right":
		orientation += 90
		if orientation >= 360:
			rot  = -3
			orientation = 0
		else:
			rot = 1
	if dir == "left":
		orientation -= 90
		if orientation < 0:
			rot  = +3
			orientation = 270
		else:
			rot = -1

	for l in layers:
		l.clear()
		destroy_highlights(l)

	for tile in used_tiles:
		var value = tile.y
		var vec3 = point_index_to_vec3(tile.x)
		var layer = get_node(str("../", vec3.z))
		buffer_array.append(rotate_coords_90(vec3, layer, value + rot, dir))
	used_tiles = buffer_array
	buffer_array = []

#	find_unwalkable_tiles()
	add_walkable_tiles()
	connect_walkable_tiles()
	spawn_highlights(walkable_tiles)
	print("rotate ", dir,  " took ", OS.get_system_time_msecs() - time, " ms to run")
	return

#========================== SIGNALS ===========================================#

func _on_Rotate_Right_pressed():
	rotate("right")
	return

func _on_Rotate_Left_pressed():
	rotate("left")
	return


#====================== Math Operations ======================================#

func rotate_coords_90(coord, layer, value, dir):
	var x = coord.x
	var y = coord.y
	var z = int(coord.z)
	var new_coordinate = Vector3(0,0,z)


	if dir == "right":
		new_coordinate.x = ((y - map_center.y) * -1) + map_center.x
		new_coordinate.y = (x - map_center.x) + map_center.y
	elif dir == "left":
		new_coordinate.x = (y - map_center.y) + map_center.x
		new_coordinate.y = ((x - map_center.x) * -1) + map_center.y
	else:
		print("HUGE ERROR MY DUDE")

	layer.set_cellv(Vector2(new_coordinate.x, new_coordinate.y), value)
	new_coordinate = calculate_point_index(new_coordinate)
	return Vector2(new_coordinate, value)

func calculate_point_index(point):
	return point.x + (map_size.x * point.y) + (map_size.x * map_size.y * point.z)
func point_index_to_vec3(point_index):
	var point = Vector3.ZERO
	point.z     = int(point_index / (map_size.x * map_size.y)) 
	point_index = point_index - (point.z * map_size.x * map_size.y)
	point.y     = int(point_index / map_size.x)
	point.x     = point_index - (point.y * map_size.x)
	return (point)

func Index_to_cell_value(index):
	var point = point_index_to_vec3(index)
	var layer = get_node(str("../", point.z))
	if point.z > layers.size() or point.x > map_size.x or point.y > map_size.y:
		print(str("theoretical point ", point, " cannot exist within current level boundaries"))
		return -1
	return layer.get_cellv(Vector2(point.x, point.y))

#==============================================================================#

