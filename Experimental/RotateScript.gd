extends Node2D

var tilemaps = []
var map_size = Vector2.ZERO
var map_center = Vector2.ZERO
var x = 0
var y = 0

func _ready():
	for tilemap in $Node2D.get_children():
		tilemaps.append(tilemap)
		if tilemap.get_used_rect().size.x > x:
			x = tilemap.get_used_rect().size.x
		if tilemap.get_used_rect().size.y > y:
			y = tilemap.get_used_rect().size.y
	
	if x > y:
		y = x
	else:
		x = y
	map_size = Vector2(x, y)
	map_center = Vector2(int(x/2), int(y/2))
	
	print("Map Size: ", map_size)
	print("Map Center: ", map_center)
	print("Good to go bitches. Fucken rotate some shit")

func _on_Rotate_Right_pressed():
	for tilemap in tilemaps:
		var array = tilemap.get_used_cells()
		for i in array:
			var value = tilemap.get_cellv(i)
			var newi = Vector2(-i.y, i.x) - map_center
			print(newi)
			tilemap.set_cellv(newi, value)
			tilemap.set_cellv(i, -1)
