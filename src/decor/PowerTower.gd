extends Node2D

func _ready():
	var label = $Label
	$Label.text = str(N.randi_range(2, 9))
	yield(get_tree(), "idle_frame")
	var scale = Vector2(1.0, 1.0)
	var font = $Label.get("custom_fonts/font") as Font
	var size = font.get_string_size($Label.text) + Vector2(5, 5)
	var color = $Label.get("custom_colors/font_color")
	color.h = N.randf()
	$Label.set("custom_colors/font_color", color)
	color.v = 0.2
	$Label.set("custom_colors/font_outline_modulate", color)
	
	for i in N.randi_range(4, 10):
		scale *= 0.75
		label = label.duplicate()
		label.rect_scale = scale
		label.rect_position.x += size.x * scale.x
		label.rect_position.y -= size.y * scale.y * 0.35
		add_child(label)
