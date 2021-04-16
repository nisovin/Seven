extends "Enemy.gd"

enum Mode { SPAWNING, COOLDOWN, ATTACKING, RESET }
enum Attack { SPINNING_AROUND, STRAFE, LANCES, NINES }

var mode = Mode.SPAWNING
var player
var heart_path_follow
var heart_path_remote
var chosen_attack = -1
var following_player = false
var returning_upright = false
var next_lance = null

func _init():
	max_health = 5000
	loot_level = 6
	drop_chance = 1.0

func spawn(p):
	visible = false
	invulnerable = true
	player = p
	heart_path_follow = get_parent().get_node("HeartPath/PathFollow2D")
	heart_path_remote = heart_path_follow.get_node("RemoteTransform2D")
	yield(get_tree().create_timer(2), "timeout")
	$AnimationPlayer.play("spawn")

func spawn_complete():
	mode = Mode.COOLDOWN
	$ModeTimer.start(3)
	invulnerable = false

func _physics_process(delta):
	if following_player:
		var a = (player.target_position - global_position).angle()
		rotation = lerp_angle(rotation, a, 3 * delta)
	elif returning_upright:
		rotation = lerp_angle(rotation, 0, 6 * delta)
		if abs(wrapf(rotation, -PI, PI)) < 0.01:
			rotation = 0
			returning_upright = false

func enable_player_following():
	following_player = true

func disable_player_following():
	following_player = false

func reset_rotation():
	returning_upright = true

func _on_ModeTimer_timeout():
	mode += 1
	if mode == Mode.RESET:
		mode = Mode.COOLDOWN
	if mode == Mode.COOLDOWN:
		$ModeTimer.start(5)
	elif mode == Mode.ATTACKING:
		choose_attack()
		
func choose_attack():
	var options = Attack.values()
	options.erase(chosen_attack)
	chosen_attack = N.rand_array(options)
	if chosen_attack == Attack.SPINNING_AROUND:
		attack_spin_around()
	elif chosen_attack == Attack.STRAFE:
		attack_strafe()
	elif chosen_attack == Attack.LANCES:
		attack_lances()
	elif chosen_attack == Attack.NINES:
		attack_nines()
	else:
		assert(false)

func attack_spin_around():
	if dead: return
	following_player = false
	returning_upright = false
	rotation = 0
	$AnimationPlayer.play("spin_heart")
	yield(get_tree().create_timer(1.5, false), "timeout")
	if dead: return
	invulnerable = true
	$SpinningBox/CollisionShape2D.disabled = false
	heart_path_remote.remote_path = heart_path_remote.get_path_to(self)
	$Tween.interpolate_property(heart_path_follow, "unit_offset", 0, 1 if N.randf() < 0.5 else -1, 6)
	$Tween.start()
	yield(get_tree().create_timer(7, false), "timeout")
	if dead: return
	heart_path_remote.remote_path = ""
	$AnimationPlayer.stop()
	$SpinningBox/CollisionShape2D.disabled = true
	returning_upright = true
	invulnerable = false
	$ModeTimer.start(1)
	
func attack_strafe():
	$AnimationPlayer.play("spikes")
	$ModeTimer.start(4)

func strafe_teleport():
	$Body.position.x = -1000

func attack_lances():
	following_player = true
	spawn_lance()
	$LanceTimer.start()
	$ModeTimer.start(8)
	
func spawn_lance():
	next_lance = R.SevenLance.instance()
	next_lance.scale.x = 0.01
	$Body/LanceSpawn.add_child(next_lance)
	$Tween.interpolate_property(next_lance, "scale:x", 0.01, 1.0, 0.5)
	$Tween.start()
	
func fire_lance():
	if next_lance != null:
		next_lance.init(100, $Body/LanceSpawn.global_position, next_lance.global_transform.x * 800)
		next_lance = null

func _on_LanceTimer_timeout():
	fire_lance()
	if mode == Mode.ATTACKING:
		spawn_lance()
	else:
		$LanceTimer.stop()
		following_player = false
		returning_upright = true

func attack_nines():
	$AnimationPlayer.play("spin_nine")
	$NineTimer.start()
	$ModeTimer.start(9)

func _on_NineTimer_timeout():
	if mode == Mode.ATTACKING:
		var bullet = R.SevenNine.instance()
		add_child(bullet)
		bullet.init(40, $Body/NineSpawn.global_position, $Body/NineSpawn.global_transform.x * 300)
		bullet.set_rotation(0)
	else:
		$NineTimer.stop()
		$AnimationPlayer.stop()
		returning_upright = true
	
func _on_hit():
	if health > 0:
		$Body/HealthBar.scale.x = health / max_health

func _on_die():
	$ModeTimer.stop()
	$LanceTimer.stop()
	$NineTimer.stop()
	$AnimationPlayer.play("die")
	yield(get_tree().create_timer(10, false), "timeout")
	queue_free()
