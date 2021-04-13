extends KinematicBody2D

export(float) var max_health = 10.0
export(float) var damage = 10.0
export(int) var subtraction = 0
export(int) var division = 0

var health: float = 0
var dead = false

func _ready():
	health = max_health
	yield(get_tree(), "physics_frame")
	if has_node("Grounder"):
		$Grounder.force_raycast_update()
		if $Grounder.is_colliding():
			global_rotation = Vector2.UP.angle_to($Grounder.get_collision_normal())
			$Grounder.force_raycast_update()
			if $Grounder.is_colliding():
				global_position += $Grounder.get_collision_point() - $Grounder.global_position

func apply_damage(dam, imag = 0):
	if dead: return
	var damage = _modify_damage(max(dam - subtraction, 0) + imag)
	health -= damage
	if health < 0: health = 0
	_on_hit()
	if health <= 0:
		die()

func die():
	dead = true
	_on_die()

func _modify_damage(dam):
	return dam

func _on_hit():
	pass

func _on_die():
	pass
