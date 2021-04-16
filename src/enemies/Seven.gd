extends "Enemy.gd"

func _init():
	max_health = 5000

func spawn(p):
	visible = false
	yield(get_tree().create_timer(2), "timeout")
	$AnimationPlayer.play("spawn")
