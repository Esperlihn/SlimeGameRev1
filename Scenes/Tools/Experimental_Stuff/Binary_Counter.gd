extends Control

export var countspeed = 0

onready var gridcontainer = $"Main/Counter/P/GridContainer"
onready var spinbox = $"Main/H/C2/V/SpinBox"
onready var number = $"Main/H2/Number"
onready var maximum_value = $"Main/H2/Maximum Value"
onready var digit_values = $"Main/H/C/Digit Values"
onready var pausebutton = $"Main/H/C2/V/C/H/Pause"
var bit_flip = []
var bit_number = 8
var bit_depth = 1
var num = 0
var second = 0
var paused = false
var maximum_number = 100000
var numbers = ["First      ", "Second ", "Third     ", "Fourth   ",\
	 "Fifth      ", "Sixth     ", "Seventh", "Eighth   "]
func _ready():
#	var a:PoolByteArray = var2bytes(2_147_483_649)
#	var a:PoolByteArray = var2bytes([7, Vector3(1, 2, 3), Vector2(1, 2), 1.0])
	var a:PoolByteArray = var2bytes(3_686_400)
	print(a.size())
	print("Huh?\n", a, "\nStill huh?")
	var b:PoolByteArray = [
		19,           #Variant Type (Array is 19)
		0,            #still unknown
		0,            #8 or 16 bit determinant???
		0,            #No idea
		3,            #Array Length Byte 1
		0,            #Array Length Byte 2
		0,            #Array Length Byte 3
		0,            #Array Length Byte 4

#Float
		3,             #Variant Type
		0,             #Unkown
		0,             #8 bit or 16 bit?
		0,             #Unkown
		0,             #Value byte #1
		0,             #Valye byte #2
		128,           #Value Byte #3
		63,            #Value Byte #4/Positive or Negative Integer

#Integer 8 bytes
		TYPE_INT,     #Variant Type
		0,            #Unkown
		0,            #8 bit or 16 bit?
		0,            #Unkown
		255,          #Value byte #1
		1,            #Valye byte #2
		0,            #Value Byte #3
		0,            #Value Byte #4/Positive or Negative Integer

#Vector3 16 bytes
#The way floats are calculated is significantly more complicated than expected
		TYPE_VECTOR3, #Variant Type
		0,            #Unknown
		0,            #Unknown
		0,            #Unknown
		0,            # X value 1
		0,            # X value 2
		64,           # X value 3
		64,           # X value 4
		0,            # Y value 1
		0,            # Y Value 2
		0,            # Y Value 3
		64,           # Y Value 4
		0,            # Z Value 1
		0,            # Z Value 2
		64,           # Z Value 3
		64,           # Z Value 4
	]
	print(bytes2var(b))
	
	for child in gridcontainer.get_children():
		bit_flip.append(child)
	_on_SpinBox_value_changed(spinbox.value)
func _process(delta):
	if paused == false:
		second += delta
		if second >= countspeed:
			_on__pressed(1)
			second = 0
	if num == maximum_number:
		_on_Pause_pressed()
		num = maximum_number + 1
func _on__pressed(value):
	num += value
	number.bbcode_text = str("[center]Number = ", num)
	var _count = bit_flip.size() - 1
	var bit_node = bit_flip[_count]
	bit_node.text = str(int(bit_node.text) + value)
	if value == 1:
		while int(bit_node.text) > bit_depth:
			bit_node.text = str(0)
			_count -= 1
			bit_node = bit_flip[_count]
			bit_node.text = str(int(bit_node.text) + value)
	else:
		while int(bit_node.text) < 0:
			bit_node.text = str(bit_depth)
			_count -= 1
			bit_node = bit_flip[_count]
			bit_node.text = str(int(bit_node.text) + value)
func _on_Pause_pressed(): paused = !paused
func _on_SpinBox_value_changed(value):
	pausebutton.pressed = false
	paused = false
	bit_depth = value - 1
	maximum_number = 1
	for i in bit_flip:
		i.text = "0"
		maximum_number = maximum_number * (bit_depth + 1)
	maximum_number = maximum_number - 1
	num = 0
	number.bbcode_text = str("[center]Number = ", num)
	maximum_value.text = str("Max Value = ", Functions.comma_sep(maximum_number))
	var counter = 1
	for i in digit_values.get_children():
		var numb = counter
		var max_value = 1
		while numb > 0:
			max_value = max_value * (bit_depth + 1)
			numb -= 1
		i.text = str(numbers[counter-1], " Bit = ", Functions.comma_sep(max_value))
		counter += 1
func _on_Reset_pressed():
	for i in bit_flip:
		i.text = "0"
		num = 0
		number.bbcode_text = "[center]Number = 0"
