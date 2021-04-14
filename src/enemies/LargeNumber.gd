extends "Enemy.gd"

func _ready():
	
	var first = N.randi_range(120, 950)
	var second = N.randi_range(120, 950)
	first = str(first)
	second = str(second)
	if first.find("7") < 0:
		var i = N.randi_range(0, first.length() - 1)
		first[i] = "7"
	if second.find("7") < 0:
		var i = N.randi_range(0, second.length() - 1)
		second[i] = "7"
	first = first.replace("7", "[color=red]7[/color]")
	second = second.replace("7", "[color=red]7[/color]")
	$Body/Left/Wing.bbcode_text = "[right]" + first + "+[/right]"
	$Body/Right/Wing.bbcode_text = "+" + second
	
	$AnimationPlayer.play("fly")

func _on_hit():
	var h = ceil(health / max_health * 99)
	if h < 10:
		h = "0" + str(h)
	else:
		h = str(h)
	$Body/Health.text = h
	var rgb = health / max_health * 0.5 + 0.5
	$Body/Health.modulate = Color(rgb, rgb, rgb)

func _on_die():
	$CollisionShape2D.set_deferred("disabled", true)
	$AnimationPlayer.play("die")
	yield(get_tree().create_timer(1.1, false), "timeout")
	queue_free()
