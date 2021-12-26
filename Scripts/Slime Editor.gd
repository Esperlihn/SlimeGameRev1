extends Control

onready var text_popup =  preload("res://Scripts/LineEdit_Popup.gd")
onready var notification = preload("res://Scenes/UI/Popups/Info_Ribbon_Popup.tscn")

onready var list = get_node("Entities/Entity_List")
onready var Health = get_node("Details/Stats_and_Texture/Stats/Stats_Container/Stat_Values/HP")
onready var Mana = get_node("Details/Stats_and_Texture/Stats/Stats_Container/Stat_Values/Mana")
onready var Attack = get_node("Details/Stats_and_Texture/Stats/Stats_Container/Stat_Values/Attack")
onready var Defence = get_node("Details/Stats_and_Texture/Stats/Stats_Container/Stat_Values/Defence")
onready var Speed = get_node("Details/Stats_and_Texture/Stats/Stats_Container/Stat_Values/Speed")
onready var Magic = get_node("Details/Stats_and_Texture/Stats/Stats_Container/Stat_Values/Magic")

var entities
var active_entity = 0
var array = []
var popup
var dict = {}
var startup = true

func _ready() -> void:
	entities = Defaults.Entities
	set_entity_display_settings()
	connect_signals()
	update_entity_data()
	update_stats(0)
	list.select(0)
	if list.get_item_count() >= 50:
		get_node("Entities/SaveLoad/Save_Load/Add_Remove/Add").disabled = true
		list.set_item_disabled(list.get_item_count(), true)
	
func set_entity_display_settings() -> void:
	var entity_display = get_node("Details/Stats_and_Texture/Texture/Entity_Display")
	for entity in entity_display.get_children():
		entity.rect_scale = Vector2(3, 3)

#=============================== Update Values ================================#
#==============================================================================#

func update_entity_data(entity_array = entities.size()) -> void:
	for i in entity_array:
		if i >= 50:
			break
		if !list.get_item_text(i):
			list.add_item(str(i))
		list.set_item_text(i, str(i+1, ". ",  entities[i]["Name"]))

func update_stats(index) -> void:
	Health.text = str(entities[index]["Health"])
	Mana.text = str(entities[index]["Mana"])
	Attack.text = str(entities[index]["Attack"])
	Defence.text = str(entities[index]["Defence"])
	Speed.text = str(entities[index]["Speed"])
	Magic.text = str(entities[index]["Magic"])

func new_health_value(value) -> void:
	entities[active_entity]["Health"] = value
func new_mana_value(value) -> void:
	entities[active_entity]["Mana"] = value
func new_attack_value(value) -> void:
	entities[active_entity]["Attack"] = value
func new_defence_value(value) -> void:
	entities[active_entity]["Defence"] = value
func new_speed_value(value) -> void:
	entities[active_entity]["Speed"] = value
func new_magic_value(value) -> void:
	entities[active_entity]["Magic"] = value


#================================== SIGNALS ===================================#
#==============================================================================#

func connect_signals() -> void:
	Health.connect("text_changed", self, "new_health_value")
	Mana.connect("text_changed", self, "new_mana_value")
	Attack.connect("text_changed", self, "new_attack_value")
	Defence.connect("text_changed", self, "new_defence_value")
	Speed.connect("text_changed", self, "new_speed_value")
	Magic.connect("text_changed", self, "new_magic_value")


func _save_changes() -> void:
	Defaults.Entities = entities
	Defaults._save_changes()
	spawn_notification("Saved!")

	
func _load_changes() -> void:
	Defaults._load_entity_data()
	entities = Defaults.Entities
	update_entity_data()

func _Entity_List_item_selected(index) -> void:
	active_entity = index
	if index > entities.size() - 1:
		return
	update_stats(index)

func _on_Rename_pressed() -> void:
	popup = text_popup.instance()
	self.add_child(popup)
	popup.connect("text_entered", self, "_change_name")
	popup.popup_centered(Vector2(40, 20))
func _change_name(text) -> void:
	entities[active_entity]["Name"] = text
	list.set_item_text(active_entity, str(active_entity + 1, ", ", text))

func _on_Add_pressed() -> void:
	if entities.size() >= 52:
		printerr("Cannot have more than 50 Entities in game")
		get_node("Entities/SaveLoad/Save_Load/Add_Remove/Add").disabled = true
		return
	var index = entities.size()
	entities[index] = Defaults.default
	update_entity_data()
func _on_Remove_pressed() -> void:
	entities.erase(active_entity)
	for i in range(active_entity, entities.size()):
		entities[i] = entities[i+1]
	list.remove_item(list.get_item_count())
	update_entity_data()
	update_stats(active_entity)
func _on_Exit_pressed() -> void:
	get_tree().current_scene.queue_free()

func spawn_notification(message) -> void:
	var a = notification.instance()
	a.message = message
	self.add_child(a)
#==============================================================================#
#==============================================================================#
#==============================================================================#
