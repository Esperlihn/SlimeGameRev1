extends Node

var console:String = ""


func logger(text):
	console += text
	console += "\n"
	update_log_file()
	return(str(text))

func print(message):
	if ProjectSettings.get_setting("logging/file_logging/enable_file_logging"):
		# Get datetime to dictionary
		var dt=OS.get_datetime()
		# Format and print with message
		print("%02d:%02d:%02d " % [dt.hour,dt.minute,dt.second], message)
	return true

func update_log_file() -> void:
	var log_file = File.new()
	log_file.open("res://Log.txt", File.WRITE)
	log_file.store_string(console)
	log_file.close()
