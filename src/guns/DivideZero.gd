extends "Gun.gd"

const Rocket = preload("DivideZeroRocket.tscn")

const PROGRESS_SIZE = 101.0
const ROCKET_START_SPEED = 150
const ROCKET_MAX_SPEED = 500
const ROCKET_ACCEL = 700

onready var muzzle = $Muzzle

var on_cooldown = false
var shooting = false

func fire():
	if not on_cooldown:
		launch()
	shooting = true
	
func stop():
	shooting = false
	
func launch():
	on_cooldown = true
	$CooldownTimer.start()
	$Barrel/Progress.rect_size.x = 0
	var rocket = Rocket.instance()
	add_child(rocket)
	var v = global_transform.x * ROCKET_START_SPEED
	var a = global_transform.x * ROCKET_ACCEL
	var damage = base_damage
	if global_transform.x.x < 0:
		rocket.set_text("==000=>")
		damage = 0
	damage = owner.modify_damage(damage)
	rocket.init(damage, muzzle.global_position, v)
	rocket.set_accel(a, ROCKET_MAX_SPEED)
	owner.knockback(-v * 0.75, 0.25)
	$AnimationPlayer.play("fire")
	
	
func _on_CooldownTimer_timeout():
	on_cooldown = false
	$Barrel/Progress.rect_size.x = PROGRESS_SIZE
	if shooting:
		launch()

func _process(delta):
	if on_cooldown:
		var time = ($CooldownTimer.wait_time - $CooldownTimer.time_left) * 0.85
		$Barrel/Progress.rect_size.x = PROGRESS_SIZE * (time / $CooldownTimer.wait_time)
