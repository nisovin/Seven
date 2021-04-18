extends "Enemy.gd"

const REVOLVE_SPEED = -PI * 0.25
const ROTATE_SPEED = PI * 0.4
const BULLET_SPEED = 150
const BULLET_PCT = 0.1

onready var outer = get_parent()

func _ready():
	owner = outer.owner
	var t = str(N.rand_array([1,2,3,4,5,6,8,9]))
	if N.randf() < 0.5:
		t = "[color=red]7[/color]" + t
	else:
		t += "[color=red]7[/color]"
	$Label.bbcode_text = "[center]" + t + "π[/center]"
	set_physics_process(false)
	var p = $DetectionArea.global_position
	$DetectionArea.set_as_toplevel(true)
	$DetectionArea.global_position = p

func _physics_process(delta):
	if dead: return
	outer.rotation += REVOLVE_SPEED * PI * delta
	rotation += ROTATE_SPEED * PI * delta

func _on_AttackArea_body_entered(body):
	body.apply_damage(damage * 1.5)


func _on_DetectionArea_body_entered(body):
	$ShootTimer.start()

func _on_DetectionArea_body_exited(body):
	$ShootTimer.stop()

func _on_ShootTimer_timeout():
	var v = -global_transform.y * BULLET_SPEED
	var bullet = R.PiBullet.instance()
	add_child(bullet)
	bullet.init(damage, global_position, v)
	bullet.set_damage(damage * BULLET_PCT, 0, BULLET_PCT)
	bullet.set_max_time(4)
	bullet.set_spin(N.randf_range(-3 * PI, 3 * PI))
	R.play_sound("pi_shoot", "Enemies")

func _on_hit():
	if health > 0:
		$Health.value = health / max_health
		
func _on_die():
	$AnimationPlayer.play("die")
	R.play_sound("pi_death", "Enemies")
	yield(get_tree().create_timer(1), "timeout")
	outer.queue_free()

func _on_VisibilityNotifier2D_screen_entered():
	set_physics_process(true)
	$DetectionArea/CollisionShape2D.disabled = false

func _on_VisibilityNotifier2D_screen_exited():
	set_physics_process(false)
	$DetectionArea/CollisionShape2D.disabled = true
	$ShootTimer.stop()
