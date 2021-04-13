extends "Gun.gd"

const Parabola = preload("Parabola.tscn")

const BULLET_SPEED = 800
const RETURN_TIME = 1

onready var muzzle = $Muzzle

var projectiles_available = 3
var shooting = false
var on_cooldown = false

func generate(lvl):
	.generate(lvl)
	if lvl >= 5:
		projectiles_available = 5
		update_text()
	elif lvl >= 3:
		projectiles_available = 4
		update_text()

func fire():
	if projectiles_available > 0 and not on_cooldown:
		launch_projectile()
	shooting = true
	
func stop():
	shooting = false

func launch_projectile():
	var damage = owner.modify_damage(base_damage)
	var parabola = Parabola.instance()
	add_child(parabola)
	parabola.init(damage, global_transform.x * BULLET_SPEED, muzzle.global_position, RETURN_TIME, self)
	projectiles_available -= 1
	update_text()
	on_cooldown = true
	$AnimationPlayer.play("fire")
	$CooldownTimer.start()

func update_text():
	$Barrel/Label.text = "( x²+" + str(projectiles_available) + "x+" + str(projectiles_available) + " -"

func _on_CaptureArea_area_entered(area):
	if area.is_in_group("parabola"):
		area.queue_free()
		projectiles_available += 1
		update_text()
		if shooting and not on_cooldown:
			launch_projectile()

func _on_CooldownTimer_timeout():
	on_cooldown = false
	if shooting and projectiles_available > 0:
		launch_projectile()
