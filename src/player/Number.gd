extends Node2D

const FONT = preload("number_font.tres")

export var color = Color.white
export var draw_width = 1.0

func _draw():
	var s = str(owner.number)
	var size = FONT.get_string_size(s)
	draw_string(FONT, -size / 2, s, color, size.x * draw_width)

func update_width(w):
	draw_width = w
	update()
