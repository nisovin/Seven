extends "Gun.gd"

const BULLET_SPEED = 600
const RELOAD_TIME = 1.5

var max_ammo = 4
var ammo = max_ammo
var shooting = false
var on_cooldown = false
var reload_progress = 0

func _init():
	gun_name = "Leading Decimal"
	short_name = "Dec."

func generate(lvl):
	.generate(lvl)
	max_ammo = 4 + lvl
	ammo = max_ammo
	update_text()

func fire():
	shooting = true
	if not on_cooldown and ammo > 0:
		shoot()
	else:
		R.play_sound("out_of_ammo", "Player")
	
func stop():
	shooting = false
	
func shoot():
	var dam = owner.modify_damage(base_damage)
	var bullet = R.DecimalBullet.instance()
	add_child(bullet)
	var v = global_transform.x * BULLET_SPEED
	#v = v.rotated(N.randf_range(-0.1, 0.1))
	bullet.init(dam, $Muzzle.global_position, v)
	on_cooldown = true
	R.play_sound("decimal_fire", "Player")
	$CooldownTimer.start()
	ammo -= 1
	if ammo == 0:
		reload()
	update_text()
	
func reload():
	reload_progress = 1
	for i in 4:
		yield(get_tree().create_timer(RELOAD_TIME / 4.0), "timeout")
		reload_progress += 1
		update_text()
	reload_progress = 0
	ammo = max_ammo
	update_text()
	yield(get_tree().create_timer(0.15), "timeout")
	if shooting and ammo > 0 and not on_cooldown:
		shoot()

func _on_CooldownTimer_timeout():
	on_cooldown = false
	if shooting and ammo > 0:
		shoot()
	
func update_text():
	var t = ""
	if reload_progress > 0:
		for i in reload_progress:
			t += "."
	else:
		t += "= 0."
	t += str(ammo) + " >"
	$Label.text = t

