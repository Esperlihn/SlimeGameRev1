extends Node
class_name Vector5

func _ready():
	print("I don't think I'll need this singleton for quite some time")
	

func path_to_self(node):
	print(get_tree().root.get_path_to(node))
	return get_tree().root.get_path_to(node)
