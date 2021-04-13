extends "Gun.gd"

const DEFAULT_LENGTH = 80
const MAX_LENGTH = 500
const EXTEND_SPEED = 400

var extending = false
var damage = 0

func fire():
	extending = true
	damage = owner.modify_damage(base_damage)
	owner.freeze_aiming = true
	owner.speed_multiplier = 0

func stop():
	extending = false
	owner.freeze_aiming = false
	owner.speed_multiplier = 1
	$Ray.rect_size.x = DEFAULT_LENGTH

func _physics_process(delta):
	if extending:
		var x = $Ray.rect_size.x + EXTEND_SPEED * delta
		$Ray.rect_size.x = x
		if x > MAX_LENGTH:
			stop()

func _on_HitBox_body_entered(body):
	if damage > 0 and body.is_in_group("damagable"):
		body.apply_damage(damage)
		if not owner.is_on_floor() and owner.jumps == 0:
			owner.jumps = 1
