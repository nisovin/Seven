extends "Bullet.gd"

onready var explosion_radius_sq = $DamageArea/CollisionShape2D.shape.radius * $DamageArea/CollisionShape2D.shape.radius

func _on_hit(body_direct_hit):
	for body in $DamageArea.get_overlapping_bodies():
		if damage > 0 and body.is_in_group("damagable"):
			var dist_sq = $DamageArea.global_position.distance_squared_to(body.global_position)
			var mult = 1 + (1 - (dist_sq / explosion_radius_sq))
			if body == body_direct_hit:
				mult += 1
			body.apply_damage(damage * mult)
			emit_signal("hit", body)
	dead = true
	$FlightParticles.emitting = false
	$ExplosionParticles.emitting = true
	$CollisionShape2D.queue_free()
	$Label.queue_free()
	yield(get_tree().create_timer(5), "timeout")
	queue_free()
