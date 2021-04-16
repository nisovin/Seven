extends "Enemy.gd"

enum Mode { SPAWNING, COOLDOWN, ANIMATING, ATTACKING, RESET }
enum Attack { CHARGED_SHOT, BARRAGE, SEEKING_ARROWS }

const MOVE_SPEED = 150

onready var arrow_spawns = [$Body/Arrow1, $Body/Arrow2, $Body/Arrow3, $Body/Arrow4]
onready var arrow_center = $Body/Arrow5

var player
var path_follow
var mode = Mode.SPAWNING
var dir = 0
var ticks_since_dir_change = 0
var chosen_attack = -1

var charged_arrow = null

# SPAWNING

func _init():
	max_health = 2000
	drop_chance = 1
	loot_level = 4

func spawn(plr):
	player = plr
	path_follow = get_parent()
	path_follow.offset = 0
	visible = false
	invulnerable = true
	$AnimationPlayer.play("spawn")
	R.play_sound("graham_spawn", "Enemies")
	#$ModeTimer.start(3)

func done_spawning():
	mode = Mode.COOLDOWN
	$ModeTimer.start()
	$MoveTimer.start()
	dir = 1
	invulnerable = false

# MOVEMENT

func _on_MoveTimer_timeout():
	if N.randf() < ticks_since_dir_change * 0.2:
		dir *= -1
		ticks_since_dir_change = 0
	else:
		ticks_since_dir_change += 1

func _physics_process(delta):
	var speed = MOVE_SPEED * dir * delta
	if health / max_health < 0.5:
		speed *= 1.5
	path_follow.offset += speed
	if mode == Mode.ATTACKING and chosen_attack == Attack.CHARGED_SHOT and charged_arrow != null:
		charged_arrow.look_at(player.global_position)

# ATTACKING

func _on_ModeTimer_timeout():
	mode += 1
	if mode == Mode.RESET:
		mode = Mode.COOLDOWN
		$AnimationPlayer.play("reset")
	if mode == Mode.COOLDOWN:
		$ModeTimer.start(4)
	elif mode == Mode.ANIMATING:
		choose_attack()
	elif mode == Mode.ATTACKING:
		pass

func choose_attack():
	var options = Attack.values()
	options.erase(chosen_attack)
	chosen_attack = N.rand_array(options)
	if chosen_attack == Attack.CHARGED_SHOT:
		$AnimationPlayer.play("power_shot_charge")
	elif chosen_attack == Attack.BARRAGE:
		$AnimationPlayer.play("barrage_charge")
	else:
		$AnimationPlayer.play("seeking_charge")
	R.play_sound("graham_choose", "Enemies")

func attack_charged_shot():
	mode = Mode.ATTACKING
	$ModeTimer.start(1.5)
	charged_arrow = R.UpArrowBullet.instance()
	arrow_center.add_child(charged_arrow)
	charged_arrow.look_at(player.global_position)
	yield(get_tree().create_timer(1, false), "timeout")
	if dead: return
	charged_arrow.init(100, charged_arrow.global_position, charged_arrow.global_transform.x * 800)
	charged_arrow = null
	R.play_sound("graham_shoot1", "Enemies")
	
func attack_barrage():
	mode = Mode.ATTACKING
	$ModeTimer.start(3)
	for a in arrow_spawns:
		var arrow = R.UpArrowBullet.instance()
		add_child(arrow)
		var v = -a.global_transform.y * 400
		v = v.rotated(deg2rad(N.randf_range(-5, 5)))
		arrow.init(30, a.global_position, v)
	$BarrageTimer.start()
	R.play_sound("graham_shoot2", "Enemies")

func _on_BarrageTimer_timeout():
	if mode != Mode.ATTACKING:
		$BarrageTimer.stop()
	else:
		var arrow = R.UpArrowBullet.instance()
		add_child(arrow)
		var spawn = N.rand_array(arrow_spawns)
		var v = -spawn.global_transform.y * 400
		v = v.rotated(deg2rad(N.randf_range(-10, 10)))
		arrow.init(30, spawn.global_position, v)
		R.play_sound("graham_shoot2", "Enemies")

func attack_seeking(i):
	if i == 0:
		mode = Mode.ATTACKING
	elif i == 3:
		$ModeTimer.start(5)
	var arrow = R.UpArrowBullet.instance()
	add_child(arrow)
	var spawn = arrow_spawns[i]
	var v = -spawn.global_transform.y * 250
	arrow.init(50, spawn.global_position, v)
	arrow.set_seeking(player, 3)
	arrow.set_max_time(7)
	R.play_sound("graham_shoot3", "Enemies")
	

# TAKING DAMAGE

func _on_hit():
	if health <= 0:
		$Body/Bracket/Health.visible = false
		$Body/Bracket/Title.visible = false
	else:
		$Body/Bracket/Health.scale.x = health / max_health
		$Body/Bracket/Title.text = "g" + str(ceil(health / max_health * 63))

func _on_die():
	$MoveTimer.stop()
	$ModeTimer.stop()
	$BarrageTimer.stop()
	$AnimationPlayer.play("die")
	R.play_sound("graham_die", "Enemies")

