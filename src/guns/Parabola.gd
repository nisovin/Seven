extends Area2D

signal hit

const ROTATION_SPEED = PI * 4

var damage = 1
var dir = Vector2.ZERO
var speed = 0
var start_pos
var accel = 0
var return_to
var returning = false

func init(dam, vel, pos, time, ret_to):
	damage = dam
	set_as_toplevel(true)
	global_position = pos
	global_rotation = vel.angle()
	speed = vel.length()
	dir = vel / speed
	start_pos = pos
	accel = speed / time
	return_to = ret_to
	print(accel)

func _physics_process(delta):
	if not returning:
		speed -= accel * delta
		if speed <= 0:
			returning = true
			speed = 0
	else:
		speed += accel * delta
		dir = global_position.direction_to(return_to.global_position)
	position += dir * speed * delta
	$Sprite.rotation += ROTATION_SPEED * delta
	
func _on_Parabola_body_entered(body):
	if damage > 0 and body.is_in_group("damagable"):
		body.apply_damage(damage)
	emit_signal("hit", body)
