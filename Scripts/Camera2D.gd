extends Camera2D

var zoom_factor     = Vector2(0.05, 0.05)
var zoom_min        = Vector2(0.2, 0.2)
var zoom_max        = Vector2(0.9, 0.9)
var mouse_held
var mouse_move      = 0
var zoom_pos        = Vector2.ZERO
onready var level   = get_node("../Map/0")
var modifier = Vector2(0, 0)
var rotation_value  = true
var debug = false

signal rotate_right
signal rotate_left


# Called when the node enters the scene tree for the first time.
func _ready():
	zoom  = Vector2(0.5, 0.5)
	scale = zoom
	if level != null:
		if connect("rotate_right", level, "_on_Rotate_Right_pressed") != 0:
			print("Rotate right function failed to connect to level")
		if connect("rotate_left", level, "_on_Rotate_Left_pressed") != 0:
			print("Rotate left function failed to connect to level")


func _process(delta):
#Click and drag function
	if mouse_move == 1:
		self.position += mouse_held - get_global_mouse_position() + modifier
#Basic timer
	var counter = 0
	counter += delta
	if counter >= 1:
		counter = 0
		print("Literally anything dude")

func _unhandled_input(event):


	if event.is_action_pressed("ui_page_down"):
		if zoom > zoom_max:
			return
		zoom += zoom_factor
		scale = zoom
		if debug == true:
			print("Zoom = ", zoom, " scale = ", scale)
		
	if event.is_action_pressed("ui_page_up"):
		if zoom < zoom_min:
			return
		zoom -= zoom_factor
		scale = zoom
		if debug == true:
			print("Zoom = ", zoom, " scale = ", scale)


	if event.is_action_pressed("mouse_left_click") or event.is_action_pressed("mouse_middle_click"):
		mouse_held = get_global_mouse_position()
		mouse_move = 1
		
	if event.is_action_released("mouse_left_click") or event.is_action_released("mouse_middle_click"):
		mouse_held = null
		mouse_move = 0


	if event.is_action_pressed("mouse_right_click"):
		if rotation_value == true:
			self.emit_signal("rotate_right")
			return
			
		if rotation_value == false:
			self.emit_signal("rotate_left")
			return


func _on_Area2D_mouse_entered():
	rotation_value = true
	if debug == true:
		print(rotation_value)
func _on_Area2D_mouse_exited():
	rotation_value = false
	if debug == true:
		print(rotation_value)
