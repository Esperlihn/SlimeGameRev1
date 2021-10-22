extends Resource
class_name Vector4

export(float) var x = 0
export(float) var y = 0
export(float) var z = 0
export(float) var w = 0

func length():
	return sqrt(x*x + y*y + z*z + w*w)
