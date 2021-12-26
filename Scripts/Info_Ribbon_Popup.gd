extends Popup

export var message:String
#
#func _ready():
#	get_node("H").rect_pivot_offset.x = get_node("H/Text").rect_size.x / 2

func _on_AnimationPlayer_animation_finished(_Fade_in_out):
	self.queue_free()

func _on_AnimationPlayer_animation_started(_Fade_in_out):
	get_node("P/Text").text = message
#	print(get_viewport_rect().size)
#	self.popup_centered(get_viewport_rect().size * -1)
