extends Node

onready var battle_scene = load("res://Scenes/Major Scenes/Battle.tscn")
onready var options = load("res://Scenes/Major Scenes/Options.tscn")
onready var title_options = get_node("PanelContainer/HBoxContainer/Title Options")



func _ready():
	$PanelContainer.set_size(OS.get_real_window_size())

func _process(_delta):
	pass


func _on_Start_pressed():
	assert(!get_tree().change_scene_to(battle_scene))


func _on_Options_pressed():
	assert(!get_tree().change_scene_to(options))


func _on_Exit_pressed():
	get_tree().quit()

