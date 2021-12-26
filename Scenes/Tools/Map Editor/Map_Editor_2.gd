extends Control

var tile_value = 0

func _gui_input(event):
	if event.is_action_pressed("mouse_left_click"):
		var tile = $TileMap.world_to_map(get_global_mouse_position())
		$TileMap.set_cellv(tile, tile_value)
	
	if event.is_action_pressed("mouse_right_click"):
		var tile = $TileMap.world_to_map(get_global_mouse_position())
		$TileMap.set_cellv(tile, -1)

