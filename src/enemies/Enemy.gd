extends KinematicBody2D

signal died

export(float) var max_health = 10.0
export(float) var damage = 10.0
export(int) var subtraction = 0
export(int) var division = 0

export(float) var drop_chance = 0.35
export(int) var loot_level = 1
export(float) var random_upgrade_chance = 0
export(bool) var guarantee_weapon_drop = false

var invulnerable = false
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

func set_invulnerable(inv: bool):
	invulnerable = inv

func apply_damage(dam, imag = 0, pct = 1.0):
	if dead or invulnerable: return
	var d = _modify_damage(max(dam - subtraction * pct, 0) * (1 - (division / 100.0)), imag)
	health -= d
	if health < 0: health = 0
	R.play_sound("enemy_hit", "Enemies")
	_on_hit()
	if health <= 0:
		die()

func die():
	dead = true
	if N.randf() <= drop_chance:
		if N.randf() < random_upgrade_chance:
			loot_level += 1
		owner.call_deferred("spawn_loot", global_position, loot_level)
	_on_die()
	emit_signal("died")

func _modify_damage(dam, imag):
	return dam + imag

func _on_hit():
	pass

func _on_die():
	pass
