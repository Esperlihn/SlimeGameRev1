"""
This file is part of:
Lihnpixel Games
https://lihnpixel.ca
***********************
Copyright (c) 2020 -2021 Sukh Atwal
"""

extends Node2D

onready var level = get_node("Map")
signal rotate_right
signal rotate_left

func _ready() -> void:
	if connect("rotate_right", level, "_on_Rotate_Right_pressed") != 0:
		print_debug(Log.logger("Level failed to connect rotate_right to tilemap"))
	if connect("rotate_left", level, "_on_Rotate_Left_pressed") !=0:
		print_debug(Log.logger("Level failed to connect rotate_left to tilemap"))

func _on_Rotate_Right_pressed() -> void:
	emit_signal("rotate_right")
func _on_Rotate_Left_pressed() -> void:
	emit_signal("rotate_left")


func _on_4_script_changed() -> void:
	print(Log.logger("Script Change"))
