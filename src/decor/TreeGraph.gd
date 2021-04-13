extends Node2D

var tree_size = floor(rand_range(3,5))
var trunk_height = rand_range(20, 40)

var brown = Color8(50, 26, 24)

func _draw():
	draw_line(Vector2.ZERO, Vector2(0, -trunk_height), brown, 5)
	draw_circle(Vector2.ZERO, 8, brown)
	_draw_branch(Vector2(0, -trunk_height), 0, tree_size)
	
func _draw_branch(pos, level, max_level):
	if level < max_level:
		var height = rand_range(20, 30)
		var branches = floor(rand_range(2, 5))
		var arc = PI / 2 + rand_range(-PI / 6, PI / 6)
		var alpha = -arc / 2 - (PI / 2)
		var delta = arc / (branches - 1)
		for i in branches:
			var leaf = pos + Vector2.RIGHT.rotated(alpha) * height
			draw_line(pos, leaf, Color(0, 0.3, 0), 3, false)
			_draw_branch(leaf, level + 1, max_level)
			alpha += delta
	draw_circle(pos, 5, Color(0, 0.5, 0))
