extends Camera2D

onready var level      = self.get_parent()

var counter         = 0
var zoom_factor     = Vector2(0.2, 0.2)
var zoom_in_min     = Vector2(0.3, 0.3)
var zoom_out_max    = Vector2(0.9, 0.9)
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


func _ready():
	zoom  = Vector2(0.6, 0.6)
	scale = zoom
	if connect("rotate_right", level, "_on_Rotate_Right_pressed") != 0:
		print("Rotate right function failed to connect to level")
	if connect("rotate_left", level, "_on_Rotate_Left_pressed") != 0:
		print("Rotate left function failed to connect to level")
#	else:
#		zoom_factor = Vector2(0.05, 0.05)
#		zoom_out_max = Vector2(0.5, 0.5)
#		zoom_in_min = Vector2(0.1, 0.1)

func _physics_process(delta):
#Basic timer
	$FPSCOUNTER.text = str("FPS: ", 1 / delta)
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


func _unhandled_input(event):
#Zoom Out
	if event.is_action_pressed("ui_page_down"):
		if zoom >= zoom_out_max:
			return
		zoom += zoom_factor
		scale = zoom
		if debug == true:
			print("Zoom = ", zoom, " scale = ", scale)
#Zoom In
	if event.is_action_pressed("ui_page_up"):
		if zoom <= zoom_in_min:
			return
		zoom -= zoom_factor
		scale = zoom
		if debug == true:
			print("Zoom = ", zoom, " scale = ", scale)

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


func _on_Area2D_mouse_entered():
	if level != null:
		rotate_right = true
		if debug == true:
			print(rotate_right)
func _on_Area2D_mouse_exited():
	if level != null:
		rotate_right = false
		if debug == true:
			print(rotate_right)
