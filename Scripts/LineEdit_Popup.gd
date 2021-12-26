extends Popup

signal text_entered

func _text_changed(text):
	emit_signal("text_entered", text)
