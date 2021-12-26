extends Node


var use_JSON = false

enum \
	{
	Name,
	Health, 
	Mana,
	Attack, 
	Defence, 
	Speed, 
	Magic, 
	Texture,
	}

var entity_default = \
	{
	"Name": "---",
	"Health":  0,
	"Mana":    0,
	"Attack":  0,
	"Defence": 0,
	"Speed":   0,
	"Magic":   0, 
	"Texture": null,
	}
var keys = []
var Entities:Dictionary = \
	{
	0 : 
		{
		"Name": "Red Slime",
		"Health":  24,
		"Mana":    0,
		"Attack":  8,
		"Defence": 0,
		"Speed":   3,
		"Magic":   0, 
		
	}, 
	
	1 : 
		{
		"Name": "Green Slime",
		"Health":  24,
		"Mana":    0,
		"Attack":  6,
		"Defence": 4,
		"Speed":   1,
		"Magic":   0, 
		
	}, 
	
	2 : 
		{
		"Name": "Blue Slime",
		"Health": 24,
		"Mana":    18,
		"Attack":  4,
		"Defence": 0,
		"Speed":   4,
		"Magic":   12, 
		
	}, 
	
	3 : 
		{
		"Name": "Yellow Slime",
		"Health":  24,
		"Mana":    0,
		"Attack":  6,
		"Defence": 0,
		"Speed":   5,
		"Magic":   8, 
		
	}, 
	
	4 : 
		{
		"Name": "Pink Slime",
		"Health":  18,
		"Mana":    12,
		"Attack":  6,
		"Defence": 0,
		"Speed":   3,
		"Magic":   8, 
		
	}, 
	
	5 : 
		{
		"Name": "Purple Slime",
		"Health":  18,
		"Mana":    12,
		"Attack":  6,
		"Defence": 0,
		"Speed":   3,
		"Magic":   0, 
		
	}, 
	
	6 : 
		{
		"Name": "White Slime",
		"Health":  12,
		"Mana":    18,
		"Attack":  4,
		"Defence": 0,
		"Speed":   3,
		"Magic":   12, 
		
	}, 
	
	7 : 
		{
		"Name": "Black Slime",
		"Health":  12,
		"Mana":    18,
		"Attack":  8,
		"Defence": 0,
		"Speed":   3,
		"Magic":   12, 
		
	}, 
	
	8 : 
		{
		"Name": "Green Slime",
		"Health":  0,
		"Mana":    0,
		"Attack":  8,
		"Defence": 0,
		"Speed":   0,
		"Magic":   0, 
		
	},
	}


func _ready():
	_load_entity_data()
	var b = Entities[0]
	for a in b:
		keys.append(a)



func _save_changes() -> void:

#Save to resource
	var filesave = File.new()
	filesave.open("res://Resources/Data/Entity_Data.tres", File.WRITE)
	filesave.store_var(Entities)
	filesave.close()

#Save to JSON
#Using JSON because it is easily edited outside of Godot
	var filesave2 = File.new()
	filesave2.open("res://Resources/Data/Entities_JSON.tres", File.WRITE)
	filesave2.store_line(to_json(Entities))
	filesave2.close()

func _load_entity_data() -> void:
	if use_JSON == false:
		var fileload = File.new()
		fileload.open("res://Resources/Data/Entity_Data.tres", File.READ)
		Entities = fileload.get_var()
		fileload.close()
	else:
		var fileload = File.new()
		fileload.open("res://Resources/Data/Entities_JSON.tres", File.READ)
		Entities = parse_json(fileload.get_line())
		fileload.close()



func _find_key(key) -> void:
	var key_array = []
	if !Entities[0].has(key):
		printerr("Selected key not found")
	for i in Entities:
		key_array.append(Entities[i][key])

func _add_key(new_key, value = null) -> void:
	for i in Entities:
		Entities[i][new_key] = value
		_save_changes()

func _remove_key(key) -> void:
	for i in Entities:
		Entities[i].erase(key)
		_save_changes()
