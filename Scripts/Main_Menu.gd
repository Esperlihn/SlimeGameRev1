extends Node

onready var battle_scene = preload("res://Scenes/Major Scenes/Battle_Testing.tscn")
onready var options = get_node("Options")
onready var title_options = get_node("CanvasLayer/P/H/Title Options")
onready var background = get_node("TextureRect/AnimationPlayer")
var thread1 = Thread.new()


func _ready() -> void:
	background.play("Oscillate")
	print(Log.logger("Main_Menu.gd Loaded"))
	for i in range(1, OS.get_screen_count() + 1):
		print(Log.logger(str("Screen ", i, " detected")))
	print(Log.logger(str("Active Screen is: Screen ", OS.WINDOW_HANDLE)))

func _on_Start_pressed() -> void:
	assert(!get_tree().change_scene_to(battle_scene))

func _on_Options_pressed() -> void:
	options.visible = !options.visible
	get_node("CanvasLayer/P").visible = !get_node("CanvasLayer/P").visible

func _on_Exit_pressed() -> void:
	get_tree().quit()

func _on_MapEditorButton_pressed():
	assert(!get_tree().change_scene("res://Scenes/Tools/Debug GUI/Debug Gui.tscn"),\
	"Main menu failed to switch to Debug GUI scene.")
