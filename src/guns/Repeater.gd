extends "Gun.gd"

const BULLET_SPEED = 350

onready var muzzle = $Muzzle

var shooting = false
var on_cooldown = false
var heat = 0

func _init():
	gun_name = "Third Repeater"
	short_name = ".333"
	flavor_text = "Fires in bursts of thirds. Less accurate, but has no down time."

func fire():
	shooting = true
	if not on_cooldown:
		fire_spray()

func stop():
	shooting = false

func _on_ShootTimer_timeout():
	on_cooldown = false
	update_text(3)
	yield(get_tree().create_timer(0.15, false), "timeout")
	if shooting and not on_cooldown:
		fire_spray()

func fire_spray():
	on_cooldown = true
	$CooldownTimer.start()
	is_actively_firing = true
	var damage = owner.modify_damage(base_damage) / 3.0
	launch_bullet(damage)
	update_text(2)
	yield(get_tree().create_timer(0.08, false), "timeout")
	launch_bullet(damage)
	update_text(1)
	yield(get_tree().create_timer(0.08, false), "timeout")
	launch_bullet(damage)
	update_text(0)
	is_actively_firing = false

func launch_bullet(dam):
	var bullet = R.RepeaterBullet.instance()
	add_child(bullet)
	var v = global_transform.x * BULLET_SPEED
	v = v.rotated(N.randf_range(-0.08, 0.08))
	bullet.init(dam, muzzle.global_position, v)
	R.play_sound("repeater_fire", "Player")

func update_text(n):
	var u = ""
	for i in n: u += "_"
	$Label.text = "  " + u + "\n0.333 >"
