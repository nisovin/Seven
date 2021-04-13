extends Area2D

signal hit

var damage = 1
var imaginary_damage = 0
var velocity = Vector2.ZERO
var accel = Vector2.ZERO
var max_speed_sq = 0
var time_left = 10
var dead = false

func init(dam, pos, vel):
	damage = dam
	set_as_toplevel(true)
	global_position = pos
	global_rotation = vel.angle()
	velocity = vel

func set_accel(acc, max_speed):
	accel = acc
	max_speed_sq = max_speed * max_speed

func set_max_time(max_t):
	time_left = max_t

func set_damage(dam, imag):
	damage = dam
	imaginary_damage = imag

func set_text(text):
	$Label.text = text
	
func _physics_process(delta):
	if dead: return
	time_left -= delta
	if time_left <= 0:
		dead = true
		queue_free()
		return
	elif time_left < 0.1:
		modulate.a = time_left / 0.1
	if accel != Vector2.ZERO and velocity.length_squared() < max_speed_sq:
		velocity += accel * delta
	position += velocity * delta

func _on_hit(body):
	if damage > 0 and body.is_in_group("damageable"):
		body.apply_damage(damage, imaginary_damage)
	emit_signal("hit", body)
	dead = true
	queue_free()
