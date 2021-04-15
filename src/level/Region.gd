extends Area2D

export(bool) var change_background = true
export(Color) var color = Color.black
export(bool) var down_reset = false
export(bool) var checkpoint = false
export(String, FILE) var music = ""

func _init():
	collision_mask = 2

func _ready():
	connect("body_entered", self, "_on_body_entered")
	connect("body_exited", self, "_on_body_exited")
	
func _on_body_entered(body):
	if change_background:
		owner.change_background_color(color)
	if down_reset:
		body.call_deferred("reset_down")
	if checkpoint:
		body.respawn_point = global_position
		
	
func _on_body_exited(body):
	if change_background and owner.new_bg == color:
		owner.change_background_color(null)
