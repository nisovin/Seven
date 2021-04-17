extends "Enemy.gd"

enum Mode { SPAWNING, COOLDOWN, CHOOSING, WAITING, ATTACKING, RESET }
enum Attack { FOUNTAIN, LANCES, AIMED }

var attack_data = {
	Attack.FOUNTAIN: {
		"number": "6[color=red]7[/color]",
		"delay": 1.5,
		"duration": 3
	},
	Attack.LANCES: {
		"number": "30[color=red]7[/color]",
		"delay": 1.5,
		"duration": 0.5
	},
	Attack.AIMED: {
		"number": "[color=red]7[/color]9[color=red]7[/color]",
		"delay": 1.5,
		"duration": 4
	}
}

var prime_numbers = [ 17, 37, 47, 67, 71, 73, 79, 97,
	107, 127, 137, 157, 167, 173, 179, 197, 227, 257, 271, 277, 307, 317, 337, 347, 367, 373, 379, 397,
	457, 467, 479, 487, 547, 557, 571, 577, 587, 607, 617, 647, 673, 677, 701, 709, 719, 727, 733, 739,
	743, 751, 757, 761, 769, 773, 787, 797, 827, 857, 877, 887, 907, 937, 947, 967, 971, 977, 997 ]

var player = null
var mode = Mode.SPAWNING
var chosen_attack = -1
var step_pos = 0
var stepping = 0

func _init():
	max_health = 500
	drop_chance = 1
	loot_level = 2

func spawn(plr):
	player = plr
	visible = false
	invulnerable = true
	$AnimationPlayer.play("spawn")
	$ModeTimer.start(3)
	R.play_sound("prime_spawn", "Enemies")

func move_left():
	stepping = -1
	
func move_right():
	stepping = 1

func stop():
	stepping = 0

func _physics_process(delta):
	if stepping != 0 and not dead:
		var v = global_transform.x * 200 * stepping
		position += v * delta

func choose_attack():
	var options = attack_data.keys()
	options.erase(chosen_attack)
	chosen_attack = N.rand_array(options)
	$Top/TopText.bbcode_text = "[center]" + attack_data[chosen_attack].number + "[/center]"

func attack():
	if chosen_attack == Attack.FOUNTAIN:
		$FountainTimer.start()
		shoot_fountain_bullets()
	elif chosen_attack == Attack.LANCES:
		shoot_lances(20)
	elif chosen_attack == Attack.AIMED:
		$AimedTimer.start()
		shoot_aimed_bullet()
	
func shoot_fountain_bullets():
	for i in 3:
		var dir = Vector2.RIGHT.rotated(-deg2rad(N.randf_range(20, 160)))
		var bullet = R.FractionBullet.instance()
		add_child(bullet)
		bullet.init(8, global_position + dir * 20, dir * 300)
		bullet.set_max_time(2.5)
		bullet.set_accel(Vector2.DOWN * 500, 200)
		bullet.set_spin(N.randf_range(-4 * PI, 4 * PI))
		R.play_sound("prime_shoot1", "Enemies")
	
func shoot_aimed_bullet():
	var dir = global_position.direction_to(player.target_position)
	var bullet = R.PrimeLance.instance()
	add_child(bullet)
	bullet.init(15, global_position + dir * 20, dir * 500)
	bullet.set_max_time(5)
	R.play_sound("prime_shoot2", "Enemies")
	
func shoot_lances(dam):
	var bullet
	for i in 5:
		bullet = R.PrimeLance.instance()
		add_child(bullet)
		bullet.init(dam, global_position + Vector2(60, -40 + 20 * i), Vector2.RIGHT * 500)
		bullet = R.PrimeLance.instance()
		add_child(bullet)
		bullet.init(dam, global_position + Vector2(-60, -40 + 20 * i), Vector2.LEFT * 500)
	R.play_sound("prime_shoot3", "Enemies")

func _on_ModeTimer_timeout():
	if dead: return
	if mode == Mode.SPAWNING:
		mode = Mode.COOLDOWN
		invulnerable = false
		$MoveTimer.start()
	mode += 1
	if mode == Mode.RESET:
		mode = Mode.COOLDOWN
	if mode == Mode.COOLDOWN:
		$ModeTimer.start(2)
		$FountainTimer.stop()
		$AimedTimer.stop()
	elif mode == Mode.CHOOSING:
		$ModeTimer.start(1.5)
		$CycleTimer.start()
		R.play_sound("prime_choose", "Enemies")
	elif mode == Mode.WAITING:
		choose_attack()
		$CycleTimer.stop()
		$ModeTimer.start(attack_data[chosen_attack].delay)
	elif mode == Mode.ATTACKING:
		attack()
		$ModeTimer.start(attack_data[chosen_attack].duration)

func _on_MoveTimer_timeout():
	if dead: return
	var dir = 0
	if step_pos == 2:
		dir = -1
	elif step_pos == -2:
		dir = 1
	else:
		dir = sign(player.global_position.x - global_position.x)
	if dir == 1:
		$AnimationPlayer.play("step_right")
	elif dir == -1:
		$AnimationPlayer.play("step_left")
	step_pos += dir
	
func _on_CycleTimer_timeout():
	if dead: return
	if mode == Mode.CHOOSING:
		$Top/TopText.bbcode_text = "[center]" + str(N.rand_array(prime_numbers)) + "[/center]"
	else:
		$CycleTimer.stop()

func _on_FountainTimer_timeout():
	if dead: return
	if mode == Mode.ATTACKING and chosen_attack == Attack.FOUNTAIN:
		shoot_fountain_bullets()

func _on_AimedTimer_timeout():
	if dead: return
	if mode == Mode.ATTACKING and chosen_attack == Attack.AIMED:
		shoot_aimed_bullet()

func _on_TooCloseArea_body_entered(body):
	if dead: return
	call_deferred("shoot_lances", 10)

func _on_hit():
	if health <= 0:
		$DivideLineFore.visible = false
	else:
		$DivideLineFore.scale.x = health / max_health
		
func _on_die():
	$ModeTimer.stop()
	$CycleTimer.stop()
	$FountainTimer.stop()
	$AimedTimer.stop()
	$MoveTimer.stop()
	$AnimationPlayer.play("die")
	R.play_sound("prime_die", "Enemies")



