"""
This file is part of:
Lihnpixel Games
https://lihnpixel.ca
***********************
Copyright (c) 2020 -2021 Sukh Atwal
"""

extends Camera2D

export var gpname:String
onready var level = \
get_node(str(self.get_path()).substr(0, str(self.get_path()).\
find(gpname)+gpname.length()))

var counter         = 0
var zoom_factor     = Vector2(0.2, 0.2)
var zoom_in_min     = Vector2(0.5, 0.5)
var zoom_out_max    = Vector2(2.5, 2.5)
var rotate_right    = true
var mouse_move
var mouse_held

var velocity = Vector2.ZERO
const friction = 1000
const acceleration = 3500
const max_speed = 400

var debug = false

signal rotate_right
signal rotate_left


func _ready() -> void:
	zoom  = Vector2(0.6, 0.6)
	scale = zoom
	assert(!connect("rotate_right", level, "_on_Rotate_Right_pressed"), "Rotate right function failed to connect to level")
	assert(!connect("rotate_left", level, "_on_Rotate_Left_pressed"), "Rotate left function failed to connect to level")

func _physics_process(delta) -> void:
#Basic timer
	counter += delta
	if counter >= 1:
		counter = 0

#Click and drag function
	if mouse_move == 1:
		self.position += mouse_held - get_global_mouse_position()

#Camera Movement Keyboard
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		velocity = velocity.move_toward(input_vector * max_speed, acceleration * delta)
		velocity = velocity.clamped(max_speed)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

	self.position = lerp(self.position, self.position + (velocity * delta), 1)


func _unhandled_input(event) -> void:
#Zoom Out
	if event.is_action_pressed("ui_page_down"):
		if zoom >= zoom_out_max:
			return
		zoom += zoom_factor
		scale = zoom
		if debug == true:
			print(Log.logger(str("Zoom = ", zoom, " scale = ", scale)))
#Zoom In
	if event.is_action_pressed("ui_page_up"):
		if zoom <= zoom_in_min:
			return
		zoom -= zoom_factor
		scale = zoom
		if debug == true:
			print(Log.logger(str("Zoom = ", zoom, " scale = ", scale)))

#Mouse Click and drag functionality
	if event.is_action_pressed("mouse_left_click") or event.is_action_pressed("mouse_middle_click"):
		mouse_held = get_global_mouse_position()
		mouse_move = 1
		
	if event.is_action_released("mouse_left_click") or event.is_action_released("mouse_middle_click"):
		mouse_held = null
		mouse_move = 0

# Right click to rotate map
	if event.is_action_pressed("mouse_right_click"):
		if rotate_right == true:
			self.emit_signal("rotate_right")
			return
			
		if rotate_right == false:
			self.emit_signal("rotate_left")
			return


func _on_Area2D_triggered(value) -> void:
	if level != null:
		rotate_right = value
		if debug == true:
			print(Log.logger(rotate_right))
