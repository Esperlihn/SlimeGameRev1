extends Node

var console:String = ""


func logger(text):
	console += text
	console += "\n"
	update_log_file()
	return(str(text))
	

func update_log_file() -> void:
	var log_file = File.new()
	log_file.open("res://Log.txt", File.WRITE)
	log_file.store_string(console)
	log_file.close()
