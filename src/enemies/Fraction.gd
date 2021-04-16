extends "Enemy.gd"

const SPEED = 100
const BULLET_SPEED = 250
const LANCE_SPEED = 400
const LANCE_DISTANCE = 150.0
const LANCE_MULTIPLIER = 1.5

export var move_range = 5

var step_pos = 0
var last_dir = 0
var stepping = 0
var target = null

func _ready():
	var top = N.randi_range(10, 99) if max_health <= 100 else N.randi_range(100, 299)
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
	set_physics_process(false)
	hide()

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
	R.play_sound("fraction_death", "Enemies")
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
		
	if target != null:
		shoot_long(position.direction_to(target.target_position))

func shoot_long(dir):
	var bullet = R.FractionBullet.instance()
	add_child(bullet)
	bullet.init(damage, global_position, dir * BULLET_SPEED)
	bullet.set_spin(N.randf_range(-2 * PI, 2 * PI))
	R.play_sound("fraction_shoot", "Enemies")
	
func shoot_short(dir):
	var bullet
	dir = dir.rotated(-deg2rad(30))
	for i in 3:
		bullet = R.FractionLance.instance()
		add_child(bullet)
		bullet.init(damage * LANCE_MULTIPLIER, global_position + dir * 10, dir * LANCE_SPEED)
		bullet.set_max_time(LANCE_DISTANCE / LANCE_SPEED)
		bullet = R.FractionLance.instance()
		add_child(bullet)
		bullet.init(damage * LANCE_MULTIPLIER, global_position - dir * 10, -dir * LANCE_SPEED)
		bullet.set_max_time(LANCE_DISTANCE / LANCE_SPEED)
		dir = dir.rotated(deg2rad(30))
	R.play_sound("fraction_shoot2", "Enemies")

func _on_DetectionZone_body_entered(body):
	target = body

func _on_DetectionZone_body_exited(body):
	target = null
	
func _on_DefensiveZone_body_entered(body):
	if not dead:
		call_deferred("shoot_short", position.direction_to(body.position))

func _on_AttackTimer_timeout():
	pass # Replace with function body.


func _on_VisibilityNotifier2D_screen_entered():
	$MoveTimer.start()
	$ShootZone/CollisionShape2D.disabled = false
	$DefensiveZone/CollisionShape2D.disabled = false
	set_physics_process(true)
	show()

func _on_VisibilityNotifier2D_screen_exited():
	$MoveTimer.stop()
	$ShootZone/CollisionShape2D.disabled = true
	$DefensiveZone/CollisionShape2D.disabled = true
	set_physics_process(false)
	hide()

