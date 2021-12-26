extends TabContainer
var array = []


func _ready():
	for i in range(50):
		array.append(i)
	self.all_tabs_in_front = true
	for i in array:
		$Slimes/HBox/ItemList.add_item(str(i))
