extends Camera2D

var zoom_factor     = Vector2(0.1, 0.1)
var zoom_min        = Vector2(0,0)
var zoom_max        = Vector2(10,10)
var mouse_held
var mouse_move      = 0
onready var level   = get_node("../Level/0")
var modifier = Vector2(0, 0)

signal rotate_right
signal rotate_left


# Called when the node enters the scene tree for the first time.
func _ready():
	zoom  = Vector2(0.5, 0.5)
	scale = Vector2(0.5, 0.5)
	if level != null:
		if connect("rotate_right", level, "_on_Rotate_Right_pressed") != 0:
			print("Rotate right function failed to connect to level")
		if connect("rotate_left", level, "_on_Rotate_Left_pressed") != 0:
			print("Rotate left function failed to connect to level")


func _process(_delta):
	if mouse_move == 1:
		self.position += mouse_held - get_global_mouse_position() + modifier

func _unhandled_input(event):
	if event.is_action_pressed("ui_page_down"):
		scale += zoom_factor
		zoom += zoom_factor
	if event.is_action_pressed("ui_page_up"):
		scale -= zoom_factor
		zoom -= zoom_factor
	if event.is_action_pressed("mouse_left_click"):
		mouse_held = get_global_mouse_position()
		mouse_move = 1
	if event.is_action_released("mouse_left_click"):
		mouse_held = null
		mouse_move = 0
	if event.is_action_pressed("mouse_right_click"):
		if get_global_mouse_position().x > 0:
			self.emit_signal("rotate_right")
		elif get_global_mouse_position().x < 0:
			self.emit_signal("rotate_left")
