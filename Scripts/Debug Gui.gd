extends Control



func _on_TabContainer_tab_changed(tab):
	if tab != 2:
		get_node("Camera2D").zoom = Vector2.ONE
		get_node("Panel").rect_size = Vector2(640, 360)
	if tab == 2:
		print(tab)
		get_node("Camera2D").zoom = Vector2(2, 2)
		get_node("Panel").rect_size = Vector2(1280, 720)
		print(get_node("Panel").rect_size)
		print(get_node("Camera2D").zoom)
