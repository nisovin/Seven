extends "Gun.gd"

const BULLET_COUNT = 8
const BULLET_SPEED = 300
const BULLET_DISTANCE = 150
const BULLET_SPREAD = PI / 16

var bullets = BULLET_COUNT
var on_cooldown = false
var shooting = false

func _init():
	gun_name = "Complexity"
	short_name = "a+bi"
	flavor_text = "Removed gun"

func fire():
	if not on_cooldown:
		launch()
	else:
		shooting = true
	
func stop():
	shooting = false
	
func launch():
	var dam = owner.modify_damage(base_damage) / float(BULLET_COUNT)
	var imag = dam * 0.33
	#dam -= imag
	for i in bullets:
		var bullet = R.ComplexBullet.instance()
		add_child(bullet)
		var v = global_transform.x.rotated(N.randf_range(-BULLET_SPREAD, BULLET_SPREAD)) * BULLET_SPEED
		var p = $Muzzle.global_position + Vector2(N.randf_range(-5, 5), N.randf_range(-5, 5))
		bullet.init(dam, p, v)
		bullet.set_damage(dam, imag)
		bullet.set_max_time(float(BULLET_DISTANCE) / float(BULLET_SPEED))
	bullets = 0
	on_cooldown = true
	update_text()
	$CooldownTimer.start()
	$AnimationPlayer.play("fire")

func update_text():
	if on_cooldown:
		$Barrel/Count.text = "0i"
	else:
		$Barrel/Count.text = str(bullets) + "i"


func _on_CooldownTimer_timeout():
	on_cooldown = false
	bullets = 3
	$ReloadTimer.start()
	update_text()
	if shooting:
		launch()
		shooting = false

func _on_ReloadTimer_timeout():
	if not on_cooldown and bullets < BULLET_COUNT:
		bullets += 1
		update_text()
		if bullets == BULLET_COUNT:
			$ReloadTimer.stop()
