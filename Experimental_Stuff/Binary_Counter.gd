extends Control
onready var bit = get_node("GridContainer/LineEdit")
onready var gridcontainer = get_node("Main/Counter/P/GridContainer")
onready var spinbox = get_node("Main/H/C2/V/SpinBox")
onready var number = get_node("Main/H2/Number")
onready var maximum_value = get_node("Main/H2/Maximum Value")
onready var digit_values = get_node("Main/H/C/Digit Values")
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
	for child in gridcontainer.get_children():
		bit_flip.append(child)
	_on_SpinBox_value_changed(spinbox.value)
func _process(delta):
	if paused == false:
		_on__pressed(1)
#		second += delta
#		if second >= 0.1:
#			_on__pressed(1)
#			second = 0
	if num == maximum_number:
		_on_Pause_pressed()
		num = maximum_number + 1
func _on__pressed(value):
	num += value
	number.bbcode_text = str("[center]Number = ", num)
	var _count = bit_flip.size() - 1
	var bit = bit_flip[_count]
	bit.text = str(int(bit.text) + value)
	if value == 1:
		while int(bit.text) > bit_depth:
			bit.text = str(0)
			_count -= 1
			bit = bit_flip[_count]
			bit.text = str(int(bit.text) + value)
	else:
		while int(bit.text) < 0:
			bit.text = str(bit_depth)
			_count -= 1
			bit = bit_flip[_count]
			bit.text = str(int(bit.text) + value)
func _on_Pause_pressed(): paused = !paused
func _on_SpinBox_value_changed(value):
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
