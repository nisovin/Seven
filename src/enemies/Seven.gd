extends "Enemy.gd"

var player
var heart_path_follow
var heart_path_remote
var following_player = false
var returning_upright = false

var next_lance = null

func _init():
	max_health = 5000

func spawn(p):
	visible = false
	player = p
	heart_path_follow = get_parent().get_node("HeartPath/PathFollow2D")
	heart_path_remote = heart_path_follow.get_node("RemoteTransform2D")
	yield(get_tree().create_timer(2), "timeout")
	$AnimationPlayer.play("spawn")

func _physics_process(delta):
	if following_player:
		var a = (player.global_position - global_position).angle()
		lerp_angle(rotation, a, 2 * delta)
	elif returning_upright:
		lerp_angle(rotation, 0, 2 * delta)
		if abs(rotation) < 0.01:
			rotation = 0
			returning_upright = false

func enable_player_following():
	following_player = true

func disable_player_following():
	following_player = false

func reset_rotation():
	returning_upright = true
	
func attack_heart():
	if dead: return
	following_player = false
	returning_upright = false
	rotation = 0
	$AnimationPlayer.play("spin")
	yield(get_tree().create_timer(1, false), "timeout")
	if dead: return
	invulnerable = true
	$SpinningBox/CollisionShape2D.disabled = false
	$Tween.interpolate_property(heart_path_follow, "unit_offset", 0, 1 if N.randf() < 0.5 else -1, 3)
	$Tween.start()
	yield(get_tree().create_timer(3, false), "timeout")
	if dead: return
	$AnimationPlayer.stop()
	$SpinningBox/CollisionShape2D.disabled = true
	returning_upright = true
	invulnerable = false
	
func attack_strafe():
	$AnimationPlayer.play("spikes")


func attack_lances():
	spawn_lance()
	$LanceTimer.start()
	
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
	# if mode == Mode.ATTACKING:
	spawn_lance()
	# else:
	# $LanceTimer.stop()
