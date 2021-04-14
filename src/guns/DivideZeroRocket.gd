extends "Bullet.gd"

onready var explosion_radius_sq = $DamageArea/CollisionShape2D.shape.radius * $DamageArea/CollisionShape2D.shape.radius

var zero = false

func fizzle():
	$Label.text = "==000=>"
	$Label.set("custom_colors/font_color", Color(.8, .8, .8))
	zero = true
	
func _on_hit(body_direct_hit):
	for body in $DamageArea.get_overlapping_bodies():
		if damage > 0 and body.is_in_group("damageable"):
			var dist = $DamageArea.global_position.distance_to(body.global_position)
			var mult = 1.0
			if body == body_direct_hit:
				mult += 0.5
			elif dist > $DamageArea/CollisionShape2D.shape.radius / 2.0:
				mult -= 0.25
			body.apply_damage(damage * mult)
	dead = true
	$FlightParticles.emitting = false
	$ExplosionParticles.emitting = true
	$CollisionShape2D.queue_free()
	$Label.queue_free()
	if zero:
		R.play_sound("dividezero_fizzle", "Player")
	else:
		R.play_sound("dividezero_explosion", "Player")
	yield(get_tree().create_timer(5), "timeout")
	queue_free()
