extends Node

var counter = 0
var seconds = 0
var curr_time = 0

func _ready():
	print("Functions.gd loaded")

func path_to_self(node):
	return get_tree().root.get_path_to(node)

func _process(delta):
	counter += delta
	if counter >= 1:
		counter = 0
		seconds += 1
#		print("Memory usage = ", OS.get_static_memory_usage()/float(100000), "Mb")
#		print(OS.get_power_percent_left())

func add_arrays(a1, a2):
	var array = []
	for a in a1:
		array.append(a)
	for a in a2:
		array.append(a)
	return array

func remove_duplicates(array):
	var newarray = []
	for a in array:
		#If new array already has this value it will not be added.
		if newarray.has(a):
			continue
		#Else. Add the value to the array
		newarray.append(a)
	return newarray

func error_check(connection, _name):
	if connection == 0:
		print(_name, " Connection Successsful")
	if connection == 1:
		print(_name, "Connection failed")

func str_to_vec2(coords):
	coords.erase(coords.find("("),1)
	coords.erase(coords.find(")"),1)
	coords.erase(coords.find(","),1)
	var x = coords.left(coords.find(" "))
	var y = coords.right(coords.find(" "))
	coords = Vector2(x,y)
	return coords

func get_time():
	var second  = seconds
	
	var day     = seconds/86400
	second      = seconds - (day * 86400)
	day         = str(day).pad_zeros(2)
	
	var hour    = second/3600
	second      = second - (hour * 3600)
	hour        = str(hour).pad_zeros(2)

	var minute  = second/60
	second      = second - (minute * 60)
	minute      = str(minute).pad_zeros(2)

	second      = str(second).pad_zeros(2)
	curr_time   = str(day, " days ", hour, " hours ", minute, " minutes ", second, " seconds")
	print(curr_time)

func vec3_to_vec2(vec3):
	var vec2 = Vector2(vec3.x, vec3.y)
	return vec2
