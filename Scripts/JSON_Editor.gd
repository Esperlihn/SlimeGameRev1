extends Control


var linebreak = "==================================================="
var data = {"Default": {"Default Para": " Default Value"}}
var state
var selected_item_key
var selected_parameter
var file_path = "res://Resources/Data/"
var file_name = "Default"
var file_type = ".tres" 

onready var popup_text = get_node("Panel/WindowDialog/Text")
onready var popup_input = get_node("Panel/WindowDialog/Text_Input")
onready var popup_ok_button = get_node("Panel/WindowDialog/Ok")
onready var info_ribbon = preload("res://Scenes/UI/Popups/Info_Ribbon_Popup.tscn")

#Important Buttons and nodes that need to be quickly referenced.
var file_dialog = FileDialog.new()
var gridcontainer = GridContainer.new()
var itemlist = ItemList.new()
var filenamenode = LineEdit.new()
var windowdialog = WindowDialog.new()
var changenamebutton#=====
var filesavebutton#=====
var fileloadbutton#=====
var cleardatabutton#=====
var newfilebutton#=====
var addparameterbutton#=====
var removeparameterbutton#=====
var addkeybutton#=====
var removekeybutton#=====
var copykeybutton#=====
var renamekeybutton#=====
var sortbutton#=====
var filterbutton#=====
var tab# Not currently in use and likely never to be.
var expected_references = 18
var reference_counter = 0
func _self_reference(node, variable):
	match variable:
		"Tab":
			tab = node
			reference_counter += 1
			tab.set_popup(file_dialog)
			print(tab.name, " Path Connection Successful")
			return
		"ItemList":
			itemlist = node
			reference_counter += 1
			print(itemlist.name, " Path Connection Successful")
			return
		"GridContainer":
			gridcontainer = node
			reference_counter += 1
			print(gridcontainer.name, " Path Connection Successful")
			return
		"Filename":
			filenamenode = node
			reference_counter += 1
			print(filenamenode.name, " Path Connection Successful")
			return
		"FileDialog":
			file_dialog = node
			file_dialog.window_title = "JSON Parser"
			reference_counter += 1
			print(file_dialog.name, " Path Connection Successful")
			return
		"WindowDialog":
			windowdialog = node
			reference_counter += 1
			print(windowdialog.name, " Path Connection Successful")
			return
		"Change_Name_Button":
			changenamebutton = node
			reference_counter += 1
			print(changenamebutton.name, " Path Connection Successful")
		"FileSaveButton":
			filesavebutton = node
			reference_counter += 1
			print(filesavebutton.name, " Path Connection Successful")
		"FileLoadButton":
			fileloadbutton = node
			reference_counter += 1
			print(fileloadbutton.name, " Path Connection Successful")
		"AddParameterButton":
			addparameterbutton = node
			reference_counter += 1
			print(addparameterbutton.name, " Path Connection Successful")
		"RemoveParameterButton":
			removeparameterbutton = node
			reference_counter += 1
			print(removeparameterbutton.name, " Path Connection Successful")
		"AddKeyButton":
			addkeybutton = node
			reference_counter += 1
			print(addkeybutton.name, " Path Connection Successful")
		"RemoveKeyButton":
			removekeybutton = node
			reference_counter += 1
			print(removekeybutton.name, " Path Connection Successful")
		"SortButton":
			sortbutton = node
			reference_counter += 1
			print(sortbutton.name, " Path Connection Successful")
		"FilterButton":
			filterbutton = node
			reference_counter += 1
			print(filterbutton.name, " Path Connection Successful")
		"CopyKeyButton":
			copykeybutton = node
			reference_counter += 1
			print(copykeybutton.name, " Path Connection Successful")
		"ClearDataButton":
			cleardatabutton = node
			reference_counter += 1
			print(cleardatabutton.name, " Path Connection Successful")
		"NewFileButton":
			newfilebutton = node
			reference_counter += 1
			print(newfilebutton.name, " Path Connection Successful")
		"RenameKeyButton":
			renamekeybutton = node
			reference_counter += 1
			print(renamekeybutton.name, " Path Connection Successful")

#This captures the variable if it doesn't match anything else
		_:
			printerr(variable, " Failed to connect!\n Reference counter is: ",\
			 reference_counter)



func _ready():
	if reference_counter != expected_references:
		printerr("Certain nodes may have failed to self-report!", \
		"\nOnly ", reference_counter, " Signals out of ", \
		expected_references, "Checked in!")
	print(linebreak, "\nJSON_Editor Ready!")
	_on_ClearDataButton_pressed()

func _on_ClearDataButton_pressed():
	data = {}
	selected_item_key = null
	file_name = ""
	itemlist.name = "itemlist"
	update()

func _on_FileLoadButton_pressed():
	file_dialog.popup_centered_ratio()

func _on_FileSaveButton_pressed():
	var path = str(file_path, file_name, file_type)
	save_file(path)

func _on_RemoveKeyButton_pressed():
	windowdialog.popup_centered()
	popup_text.bbcode_text = "[center]Are you sure you want to remove this Key?"
	popup_input.visible = false
	popup_ok_button.grab_focus()
	state = "RemoveKey"

func _on_AddKeyButton_pressed():
	windowdialog.popup_centered()
	popup_text.bbcode_text = "[center] Please Enter a name"
	popup_input.grab_focus()
	state = "AddKey"

func _on_RemoveParameterButton_pressed():
	windowdialog.popup_centered()
	popup_text.bbcode_text = str("[center] Are you you want to remove ", \
	selected_parameter, " from ALL keys in file?")
	popup_input.visible = false
	popup_input.grab_focus()
	state = "RemoveParameter"

func _on_AddParameterButton_pressed():
	windowdialog.popup_centered()
	popup_text.bbcode_text = "[center] Please Name New Parameter:"
	popup_input.grab_focus()
	state = "AddParameter"

func _on_popup_text_entered(new_text):
	if typeof(new_text) == TYPE_BOOL:
		new_text = popup_input.text
	match state:
		"AddKey":
			clear_popup()
			add_new_key(new_text)
			if itemlist.get_item_count() == 0:
				add_new_key("Default")
			update()
		
		"RemoveKey":
			clear_popup()
			data.erase(selected_item_key)
			selected_item_key = null
			popup_input.visible = true
			update()

		"AddParameter":
			clear_popup()
			add_new_parameter(new_text)
			update()
			
		"RemoveParameter":
			clear_popup()
			remove_selected_parameter()
			update()
			popup_input.visible = true
		_:
			print(new_text)

func update():
	update_gridcontainer()
	update_itemlist()
	update_filenamenode()
func update_itemlist():
	itemlist.clear()
	for key in data:
		if key == "Default":
			continue
		itemlist.add_item(key)
func update_gridcontainer():
	var key = selected_item_key
	var counter = 0
	
	for node in gridcontainer.get_children():
		node.get_child(0).text = ""
		node.get_child(1).name = "Value"
		node.get_child(1).text = ""
		node.get_child(1).editable = false
		
	if key == null:
		return

	for parameter in data[key]:
		var key_node = gridcontainer.get_child(counter).get_child(0)
		var value_node = gridcontainer.get_child(counter).get_child(1)
		key_node.text = parameter
		value_node.text = str(data[key][parameter])
		value_node.editable = true
		value_node.name = parameter
		counter += 1
func update_filenamenode():
	filenamenode.text = file_name

func _on_ItemList_item_selected(index):
	selected_item_key = itemlist.get_item_text(index)
	update_gridcontainer()

func _on_FileDialog_file_selected(path):
	path_variables_from_path(path)
	filenamenode.text = file_name
	path = str(file_path, file_name, file_type)
	itemlist.name = file_name
	load_file(path)
	

#Observed when you select a key in the gridcontainer
func _on_Key_Selected(parameter):
	selected_parameter = parameter
	print(selected_parameter)

#Observed when you hit enter after changing a value in the gridcontainer
func _on_Value_text_changed(value, parameter):
	var key = selected_item_key
	var dict = data[key].duplicate()
	dict[parameter] = value
	data[key] = dict

func clear_popup():
	windowdialog.visible = false
	popup_input.clear()
	popup_text.bbcode_text = ""
func add_new_key(Key_name):
	if data.has("Default"):
		data[Key_name] = data["Default"]
	else:
		var dictionary = {}
		data[Key_name] = dictionary
	selected_item_key = Key_name
func add_new_parameter(Parameter_name):
	for key in data:
		data[key][Parameter_name] = "Blank"
func remove_selected_parameter():
	for key in data:
		data[key].erase(selected_parameter)
func path_variables_from_path(path):
	var file_name_start = path.find_last("/") + 1
	var file_name_end = path.find_last(".")
	var file_name_length = file_name_end - file_name_start
	
	file_path = path.substr(0, file_name_start)
	file_name = path.substr(file_name_start, file_name_length)
	file_type = path.substr(file_name_end)
	
	return path.substr(file_name_start, file_name_length)
func load_file(path):
	var file = File.new()
	file.open(path, File.READ)
	data = parse_json(file.get_line())
	file.close()
	update()
func save_file(path):
	var file = File.new()
	file.open(path, File.WRITE)
	file.store_line(to_json(data))
	file.close()
	var ribbon = info_ribbon.instance()
	self.add_child(ribbon)
	ribbon.message = "Saved!"
	ribbon.popup()
	print(OS.get_real_window_size())

func _on_Change_Name_Button_pressed():
	filenamenode.editable = !filenamenode.editable
	filenamenode.selecting_enabled = !filenamenode.selecting_enabled
	filenamenode.focus_mode = wrapi(filenamenode.focus_mode -2, 0, 4)

func _on_Filename_text_entered(new_text):
	file_name = new_text
# Doesn't emit signal so func has to be manually called after flipping button
	changenamebutton.pressed = false
	_on_Change_Name_Button_pressed()

func _on_Filename_focus_exited():
	filenamenode.text = file_name


func _on_Print_pressed():
	for key in data:
		print(key, data[key])

