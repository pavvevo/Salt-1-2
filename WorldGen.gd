extends StaticBody3D

func _ready():
	var image = load("res://icon.svg")
	var data = image.get_data()
	data.lock()
	var pixel = data.get_pixel(1,2)
	print(pixel)
