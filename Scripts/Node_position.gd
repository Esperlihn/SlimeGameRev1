"""
REMEBER TO ENTER IN THE GPNAME IN THE EDITOR AS IT IS AN EXPORT VARIABLE
MAKE ABSOLUTELY SURE YOU REMEMBER TO OR THIS SCRIPT WILL NOT WORK AT ALL
"""

extends Node

signal pathtoself

export var gpname:String


func _ready() -> void:
	var path = str(self.get_path())
	var grandparent = get_node(path.substr(0, path.find(gpname)+gpname.length()))
	if connect("pathtoself", grandparent, "_self_reference"):
		printerr(self.name, " failed to connect to root node")
		print(self.get_path())
	emit_signal("pathtoself", self, self.name)
