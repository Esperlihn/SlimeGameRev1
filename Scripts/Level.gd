extends Node2D

onready var level = get_node("Map/0")
signal rotate_right
signal rotate_left
func _ready():
	if connect("rotate_right", level, "_on_Rotate_Right_pressed") != 0:
		print_debug("Level failed to connect rotate_right to tilemap")
	if connect("rotate_left", level, "_on_Rotate_Left_pressed") !=0:
		print_debug("Level failed to connect rotate_left to tilemap")
func _on_Rotate_Right_pressed():
	emit_signal("rotate_right")
func _on_Rotate_Left_pressed():
	emit_signal("rotate_left")
