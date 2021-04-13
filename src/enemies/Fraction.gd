extends "Enemy.gd"

const SPEED = 100

export var move_range = 5

var step_pos = 0
var last_dir = 0
var stepping = 0
var target = null

func _ready():
	var top = N.randi_range(3, 99)
	var bottom = N.randi_range(top + 1, 999)
	top = str(top)
	bottom = str(bottom)
	if top.find("7") < 0 and bottom.find("7") < 0:
		if N.randf() < 0.5:
			var i = N.randi_range(0, top.length() - 1)
			top[i] = "7"
		else:
			var i = N.randi_range(0, bottom.length() - 1)
			bottom[i] = "7"
	top = top.replace("7", "[color=red]7[/color]")
	bottom = bottom.replace("7", "[color=red]7[/color]")
	$Top/Top2.bbcode_text = "[center]" + top + "[/center]"
	$Bottom/Bottom2.bbcode_text = "[center]" + bottom + "[/center]"
	yield(get_tree().create_timer(N.randf_range(0, $MoveTimer.wait_time)), "timeout")
	$MoveTimer.start()

func move_left():
	stepping = -1
	
func move_right():
	stepping = 1

func stop():
	stepping = 0

func _physics_process(delta):
	if stepping != 0 and not dead:
		var v = global_transform.x * SPEED * stepping
		position += v * delta

func _on_hit():
	if health <= 0:
		$DivideLineFore.visible = false
	else:
		$DivideLineFore.scale.x = health / max_health

func _on_die():
	$CollisionShape2D.set_deferred("disabled", true)
	$AnimationPlayer.play("die")
	yield(get_tree().create_timer(1.1, false), "timeout")
	queue_free()

func _on_MoveTimer_timeout():
	if dead: return
	var dir = 0
	if N.randf() < 0.25:
		dir = 0
	elif step_pos == move_range:
		dir = -1
	elif step_pos == -move_range:
		dir = 1
	else:
		var options = []
		if step_pos < move_range and last_dir == 1:
			options.append(1)
			options.append(1)
		if step_pos > -move_range and last_dir == -1:
			options.append(-1)
			options.append(-1)
		for i in move_range:
			if step_pos < 0 and -i < step_pos:
				options.append(-1)
			else:
				options.append(1)
			if step_pos > 0 and i > step_pos:
				options.append(1)
			else:
				options.append(-1)
		dir = N.rand_array(options)
	last_dir = dir
	step_pos += dir
	if dir > 0:
		$AnimationPlayer.play("step_right")
	elif dir < 0:
		$AnimationPlayer.play("step_left")
		
	if target != null and N.randf() < 0.5:
		pass


func _on_DetectionZone_body_entered(body):
	target = body

func _on_DetectionZone_body_exited(body):
	target = null

func _on_AttackTimer_timeout():
	pass # Replace with function body.
