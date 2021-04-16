extends Area2D

var damage = 1
var imaginary_damage = 0
var damage_percent = 1.0
var velocity = Vector2.ZERO
var accel = Vector2.ZERO
var seek_target = null
var seek_accel = 0
var seek_max = 0
var spin_speed = 0
var spin_node = null
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

func set_seeking(target, acc):
	seek_target = target
	seek_accel = acc
	seek_max = velocity.length()

func set_spin(speed, node = "."):
	spin_speed = speed
	spin_node = get_node(node)

func set_max_time(max_t):
	time_left = max_t

func set_damage(dam, imag, pct = 1.0):
	damage = dam
	imaginary_damage = imag
	damage_percent = pct

func set_text(text, node = "Label"):
	get_node(node).text = text

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
	if seek_target != null:
		var desired = global_position.direction_to(seek_target.global_position) * velocity.length()
		velocity += desired * seek_accel * delta
		velocity = velocity.clamped(seek_max)
		global_rotation = velocity.angle()
	position += velocity * delta
	if spin_node != null:
		spin_node.rotation += spin_speed * delta

func _on_hit(body):
	if damage > 0 and body.is_in_group("damageable"):
		body.apply_damage(damage, imaginary_damage, damage_percent)
	dead = true
	queue_free()
