extends Area2D

export var color = Color.black

func _ready():
	collision_mask = 2
	connect("body_entered", self, "_on_body_entered")
	connect("body_exited", self, "_on_body_exited")
	
func _on_body_entered(body):
	if color != Color.black:
		print("yes")
		owner.change_background_color(color)
	
func _on_body_exited(body):
	if color != Color.black and owner.new_bg == color:
		owner.change_background_color(null)
