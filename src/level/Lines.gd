tool
extends Node2D

export var update_all_lines = false setget do_update

func do_update(x):
	update_lines(self)

func update_lines(node):
	for n in node.get_children():
		if n is Line2D and n.has_method("update_line"):
			n.update_line(true)
		elif n is Node2D:
			update_lines(n)
