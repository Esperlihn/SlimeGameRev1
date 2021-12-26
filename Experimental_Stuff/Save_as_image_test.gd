extends Control


onready var image = Image.new()
var map_size
var map_height
var map_data
var png_save_path = "res://Save_1.png"
var color_array = [Color.transparent,Color.darkslateblue,Color.cornflower,\
Color.aquamarine,Color.darkblue,Color.orange,Color.pink,Color.yellow]
var color_array3 = []
var color_values = [0, 63, 127, 191, 255]


func _ready():
	_create_color_palette(color_array3)
#	save_color_palette(color_array3)
	save_map_as_image()
	load_map_from_image()
	get_tree().quit()

func _create_color_palette(source):
	source.append(Color8(0,0,0,0))
	for red in color_values:
		for green in color_values:
			for blue in color_values:
#				source.append(Color8(red, green, blue))
				for alpha in color_values:
					if alpha == 0:
						continue
					source.append(Color8(red, green, blue, alpha))

func save_color_palette(source):
	var position = Vector2(0,0)	
	image.create(source.size(), 1, false, Image.FORMAT_RGBA8)
	image.lock()
	for i in source:
		image.set_pixelv(position, i)
		position.x += 1
	image.unlock()
	image.save_png("res://color_palette.png")
	image.resize(source.size() * 4, 4, 0)
	image.save_png("res://color_palette2.png")

func save_map_as_image():
	var counter = 0
	var increment = true
	var increment_value = 1
	var move_value = 1
	var current_point = Vector2(32, 32)
	var move_dir = "Right"
	var direction = {
		"Right": Vector2(1, 0), "Left": Vector2(-1, 0),
		"Up": Vector2(0, -1), "Down": Vector2(0, 1)
	}
	
	load_map_from_array()
	image.create(64, 64, false, Image.FORMAT_RGBA8)
	image.lock()
#	image.set_pixel(32, 32, Color.black)
	for tile_value in map_data:
		var color = color_array[tile_value] #Color to use for value of index point
		image.set_pixelv(current_point, color)

		if move_value > 0:
			current_point += direction[move_dir]
			move_value -= 1

		else:
			if increment == true:
				increment_value += 1
			increment = !increment
			
			match move_dir:
				"Right":
					move_dir = "Up"
					current_point += direction[move_dir]
				"Up":
					move_dir = "Left"
					current_point += direction[move_dir]
				"Left":
					move_dir = "Down"
					current_point += direction[move_dir]
				"Down":
					move_dir = "Right"
					current_point += direction[move_dir]
			
			move_value = increment_value - 1
		counter += 1

	image.unlock()
	image.save_png(png_save_path)
	image.resize(512, 512, 0)
	image.save_png("res://image1.png")

func load_map_from_image():
	var array = []
	var current_position:Vector2
	
	var increment = true
	var increment_value = 1
	var move_value = 1
	var move_dir = "Right"
	var direction = {
		"Right": Vector2(1, 0), "Left": Vector2(-1, 0),
		"Up": Vector2(0, -1), "Down": Vector2(0, 1)
	}
	image.load(png_save_path)
	image.lock()

	if image.get_pixelv(image.get_size() / 2) == Color.black:
		current_position = image.get_size() / 2
		current_position.y += 1
		print("Image Center Found!")

	for index in range(0, (image.get_width()*image.get_height())):
		var value = image.get_pixelv(current_position)
		value.r = stepify(value.r, 0.01)
		value.g = stepify(value.g, 0.01)
		value.b = stepify(value.b, 0.01)
		value.a = stepify(value.a, 0.01)
		if color_array.find(value) == -1:
			if value.r == 0 and value.g == 0 and value.b == 0:
				value.r = 1
				value.g = 1
				value.b = 1
				if color_array.find(value) == -1:
					printerr("BIG ERROR")
					print(map_data.size())
					printerr("\n", index,"\n", value, "\n", color_array)
					break
		value = color_array.find(value)
		array.append(value)

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

	for n in range(0, map_data.size()):
		if array[n] != map_data[n]:
			prints("Fuck.", n)

	image.unlock()

func load_map_from_array() -> void:
	var file
	var data
	var array = []

	file = File.new()
	file.open("res://array_new.txt", File.READ)
	data = file.get_line()
	map_size = Functions.str_to_vec2(file.get_line())
	map_height = int(file.get_line())
	file.close()
	
	for i in data:
		array.append(int(i))
	map_data = array
