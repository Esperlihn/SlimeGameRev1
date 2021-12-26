extends HBoxContainer

signal textchange(value1, value2)
signal keyselected
onready var value_node = get_node("Value")
onready var key_node = get_node("Key")
onready var key = value_node.name
onready var gpname = "JSON_Editor"
onready var root = get_node(str(self.get_path()).substr(0, str(self.get_path()).\
find(gpname)+gpname.length()))

func _ready():
#	value_node.connect("text_changed", self, "_emitter")
	value_node.connect("text_entered", self, "_emitter")
	value_node.connect("focus_entered", self, "active_key")
	if connect("keyselected", root, "_on_Key_Selected"):
		printerr("0 was unable to connect keyselected to ", root.name)
	if connect("textchange", root, "_on_Value_text_changed"):
		printerr("Key and Value display nodes failed to connect to ", root.name)
#	value_node.connect("focus_entered", self, "_focused")

func _emitter(new_text):
	emit_signal("textchange", new_text, value_node.name)

func active_key():
	emit_signal("keyselected", value_node.name)
