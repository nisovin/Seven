extends Node2D

export var rows = 0

var widths = [5, 10, 20, 26, 34, 48, 60, 72, 88]


func ready():
	var size = rows if rows > 0 else floor(N.randf_range(5, 9))
	var text = "1\n1 1"
	var prev_row = [1,1]
	for i in range(2, rows):
		var this_row = []
		text += "\n1 "
		this_row.append(1)
		for j in prev_row.size() - 1:
			var n = prev_row[j] + prev_row[j+1]
			text += str(n) + " "
			this_row.append(n)
		text += "1"
		this_row.append(1)
		prev_row = this_row
	$Label.text = text
	#var lines = $Label.text.split("\n")
	#lines.resize(size)
	#$Label.text = PoolStringArray(lines).join("\n")
	#$StaticBody2D/CollisionShape2D.shape.height = widths[size - 1] * 2 - 20

	var font = $Label.get("custom_fonts/font") as Font

	var c1 = Color.from_hsv(N.randf(), 1, 0.6)
	var c2 = Color.from_hsv(c1.h, 1, 0.3)
	$Label.set("custom_colors/font_color", c1)
	$Label.set("custom_colors/font_outline_modulate", c2)
