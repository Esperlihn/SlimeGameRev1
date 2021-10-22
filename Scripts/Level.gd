extends Node2D

export var threadcount = 1
export var n           = 5
var arrayjuggler= threadcount - 1

var thread1  = Thread.new()
var thread2  = Thread.new() 
var thread3  = Thread.new() 
var thread4  = Thread.new() 
var thread5  = Thread.new() 
var thread6  = Thread.new() 
var thread7  = Thread.new() 
var thread8  = Thread.new() 

onready var arrays = [array1, array2, array3, array4, array5, array6, array7, array8]
var threads = [thread1, thread2, thread3, thread4, thread5, thread6, thread7, thread8]
var array1 = []
var array2 = []
var array3 = []
var array4 = []
var array5 = []
var array6 = []
var array7 = []
var array8 = []
var count1 = 0
var count2 = 0
var count3 = 0
var count4 = 0
var count5 = 0
var count6 = 0
var count7 = 0
var count8 = 0
var time
var function = 0

func _ready():
	time = OS.get_system_time_msecs()
	for y in range (0, n):
		for x in range(0, n):
			var cell = Vector2(x, y)
			if arrayjuggler == -1:
				arrayjuggler = threadcount -1
			var array = arrays[arrayjuggler]
			array.append(cell)
			arrayjuggler -=1
	print("Starup took: ", OS.get_system_time_msecs() - time, " milliseconds to generate arrays totaling ", \
	n*n, " numbers")
	
	print("starting thread")
	time = OS.get_system_time_msecs()
	thread1.start(self, "threadedFunction1")
	thread2.start(self, "threadedFunction2")
	thread3.start(self, "threadedFunction3")
	thread4.start(self, "threadedFunction4")
	thread5.start(self, "threadedFunction5")
	thread6.start(self, "threadedFunction6")
	thread7.start(self, "threadedFunction7")
	thread8.start(self, "threadedFunction8")
	print("waiting to finish")
	thread1.wait_to_finish()
	thread2.wait_to_finish()
	thread3.wait_to_finish()
	thread4.wait_to_finish()
	thread5.wait_to_finish()
	thread6.wait_to_finish()
	thread7.wait_to_finish()
	thread8.wait_to_finish()
	print("finished")

func threadedFunction1(var _data):
	count1 = test_process1(array1)
	call_deferred("done1")
func threadedFunction2(var _data):
	count2 = test_process1(array2)
	call_deferred("done2")
func threadedFunction3(var _data):
	count3 = test_process1(array3)
	call_deferred("done3")
func threadedFunction4(var _data):
	count4 = test_process1(array4)
	call_deferred("done4")
func threadedFunction5(var _data):
	count5 = test_process1(array5)
	call_deferred("done5")
func threadedFunction6(var _data):
	count6 = test_process1(array6)
	call_deferred("done6")
func threadedFunction7(var _data):
	count7 = test_process1(array7)
	call_deferred("done7")
func threadedFunction8(var _data):
	count8 = test_process1(array8)
	call_deferred("done8")
func done1():
	if count1 != 0:
		print("thread1 done, array1 has ", array1.size(), " objects left")
		print("thread1 took: ", OS.get_system_time_msecs() - time, " milliseconds to iterate ", \
		count1, " numbers")
	else:
		pass
func done2():
	if count2 == 0:
		pass
	else:
		print("thread2 done, array2 has ", array2.size(), " objects left")
		print("thread2 took: ", OS.get_system_time_msecs() - time, " milliseconds to iterate ", \
		count2, " numbers")
func done3():
	if count3 == 0:
		pass
	else:
		print("thread3 done, array3 has ", array3.size(), " objects left")
		print("thread3 took: ", OS.get_system_time_msecs() - time, " milliseconds to iterate ", \
		count3, " numbers")
func done4():
	if count4 == 0:
		pass
	else:
		print("thread4 done, array4 has ", array4.size(), " objects left")
		print("thread4 took: ", OS.get_system_time_msecs() - time, " milliseconds to iterate ", \
		count4, " numbers")
func done5():
	if count5 == 0:
		pass
	else:
		print("thread5 done, array5 has ", array5.size(), " objects left")
		print("thread5 took: ", OS.get_system_time_msecs() - time, " milliseconds to iterate ", \
		count5, " numbers")
func done6():
	if count6 == 0:
		pass
	else:
		print("thread6 done, array6 has ", array6.size(), " objects left")
		print("thread6 took: ", OS.get_system_time_msecs() - time, " milliseconds to iterate ", \
		count6, " numbers")
func done7():
	if count7 == 0:
		pass
	else:
		print("thread7 done, array7 has ", array7.size(), " objects left")
		print("thread7 took: ", OS.get_system_time_msecs() - time, " milliseconds to iterate ", \
		count7, " numbers")
func done8():
	if count8 == 0:
		pass
	else:
		print("thread8 done, array8 has ", array8.size(), " objects left")
		print("thread8 took: ", OS.get_system_time_msecs() - time, " milliseconds to iterate ", \
		count8, " numbers")



func test_process1(array):
	var count = 0
	if array.size() >= 0:
		for i in range (0, array.size()):
			i = array.size() - 1
			array.remove(i)
			count += 1
	return count

func test_process0():
	pass

func _on_Reload_pressed():
	$TileMap.clear()
	$TileMap._generate_map()


func _on_Clear_Button_pressed():
	$TileMap.clear()
	$TileMap._generate_map2()

#func _exit_tree():
#	thread.wait_to_finish()


func _on_Button_pressed():
	time = OS.get_system_time_msecs()
	$TileMap.clear()
	print("Clear button took: ", OS.get_system_time_msecs() - time, " milliseconds to delete ", \
	$TileMap.mapmaker.size(), " tiles")
