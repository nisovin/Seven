extends "Enemy.gd"

const SPEED = 100
const BULLET_SPEED = 250
const BULLET_COUNT = 10
const DIVE_SPEED = 350
const DIVE_DISTANCE = 250

export var wander_range = 120

onready var spawn_position = global_position
onready var target_pos = global_position

var shooting = false
var diving = false
var bullets_shot = 0
var dive_distance = 0
var target_dir = Vector2.ZERO

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

# WANDER

func _on_WanderTimer_timeout():
	target_pos = spawn_position + Vector2(N.randf_range(-wander_range, wander_range), N.randf_range(-wander_range / 2, wander_range / 2))
	
func _physics_process(delta):
	if dead: return
	if diving:
		global_position += target_dir * DIVE_SPEED * delta
		dive_distance += DIVE_SPEED * delta
		if dive_distance >= DIVE_DISTANCE:
			diving = false
			target_pos = spawn_position
			$AnimationPlayer.play("fly")
	elif not shooting:
		global_position = global_position.move_toward(target_pos, SPEED * delta)

# ATTACKING

func _on_CooldownTimer_timeout():
	if dead: return
	var bodies = $ShootZone.get_overlapping_bodies()
	if bodies.size() > 0:
		target_dir = global_position.direction_to(bodies[0].global_position)
		shooting = true
		bullets_shot = 0
		$RepeatFireTimer.start()
		return
	bodies = $DropZone.get_overlapping_bodies()
	if bodies.size() > 0:
		target_dir = global_position.direction_to(bodies[0].global_position)
		diving = true
		dive_distance = 0
		$AnimationPlayer.play("dive")
		R.play_sound("largenum_dive", "Enemies")
	
func _on_RepeatFireTimer_timeout():
	if dead: return
	shoot_bullet()
	if bullets_shot >= BULLET_COUNT:
		shooting = false
		$RepeatFireTimer.stop()
		
func shoot_bullet():
	bullets_shot += 1
	var bullet = R.LargeNumberBullet.instance()
	add_child(bullet)
	bullet.init(1, global_position, target_dir * BULLET_SPEED)
	bullet.set_damage(damage / float(BULLET_COUNT), 0, 1 / float(BULLET_COUNT))
	if bullets_shot == 1 or bullets_shot == BULLET_COUNT:
		bullet.set_text(str(N.randi_range(1, 9)))
	else:
		bullet.set_text(str(N.randi_range(0, 9)))
	if target_dir.x < 0:
		bullet.global_rotation += PI
	R.play_sound("largenum_shoot", "Enemies")

func _on_DiveHitBox_body_entered(body):
	if body.is_in_group("damageable"):
		body.apply_damage(damage * 1.25)
		
# TAKING DAMAGE

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
	$CooldownTimer.stop()
	$RepeatFireTimer.stop()
	$WanderTimer.stop()
	$CollisionShape2D.set_deferred("disabled", true)
	$AnimationPlayer.play("die")
	R.play_sound("largenum_death", "Enemies")
	yield(get_tree().create_timer(1.1, false), "timeout")
	queue_free()




func _on_VisibilityNotifier2D_screen_entered():
	$CooldownTimer.start()
	$WanderTimer.start()
	$ShootZone/CollisionShape2D.disabled = false
	$ShootZone/CollisionShape2D2.disabled = false
	$DropZone/CollisionShape2D.disabled = false

func _on_VisibilityNotifier2D_screen_exited():
	$CooldownTimer.stop()
	$WanderTimer.stop()
	$ShootZone/CollisionShape2D.disabled = true
	$ShootZone/CollisionShape2D2.disabled = true
	$DropZone/CollisionShape2D.disabled = true


