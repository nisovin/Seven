tool
extends Node2D

export var tree_size = 0
export var trunk_height = 0
export var color_trunk = Color8(80, 41, 38)
export var color_branch = Color(0, 0.3, 0)
export var color_leaf = Color(0, 0.5, 0)

func _draw():
	var size = tree_size if tree_size > 0 else floor(rand_range(3,5))
	var h = trunk_height if trunk_height > 0 else rand_range(20, 40)
	draw_line(Vector2.ZERO, Vector2(0, -h), color_trunk, 5)
	draw_circle(Vector2.ZERO, 8, color_trunk)
	_draw_branch(Vector2(0, -h), 0, size)
	
func _draw_branch(pos, level, max_level):
	if level < max_level:
		var height = rand_range(20, 30)
		var branches = 2 if level >= 2 else int(floor(rand_range(2, 4)))
		var arc = PI / 2 + rand_range(-PI / 6, PI / 6)
		var alpha = -arc / 2 - (PI / 2)
		var delta = arc / (branches - 1)
		for i in branches:
			var leaf = pos + Vector2.RIGHT.rotated(alpha) * height
			draw_line(pos, leaf, color_branch, 3, false)
			_draw_branch(leaf, level + 1, max_level)
			alpha += delta
	draw_circle(pos, 5, color_leaf)
