extends "Enemy.gd"

const CHARGE_RANGE = 250
const CHARGE_SPEED = 200
const RETURN_SPEED = 75
const NUMBER_COUNT = 20
const NUMBER_SPEED_NORMAL = 0.2
const NUMBER_SPEED_MOVING = 0.6
const NUMBER_SPEED_DEAD = 1.2
const DIGITS = [0, 1, 2, 3, 4, 5, 6, 7, 7, 7, 7, 8, 9]
const MOVE_ANIM_DUR = 1.0

onready var path = $Mover/Path2D

var default_color
var dir = 1
var charging = false
var spawn_point
var target = null
var player_in_area = false
var charge_to = 0

func _ready():
	spawn_point = global_position
	var num = $Mover/Path2D/NumberFollower
	default_color = num.get_node("Label").get("custom_colors/font_color")
	for i in NUMBER_COUNT - 1:
		var new = num.duplicate()
		set_random_number(new.get_node("Label"))
		path.add_child(new)
		new.unit_offset = (i + 1) / float(NUMBER_COUNT)
	call_deferred("setup")
		
func setup():
	var pos = $ChargeArea.global_position
	$ChargeArea.set_as_toplevel(true)
	$ChargeArea.global_position = pos

func _process(delta):
	for n in path.get_children():
		var d = 0
		if charging:
			d = NUMBER_SPEED_MOVING
		elif dead:
			d = NUMBER_SPEED_DEAD
		else:
			d = NUMBER_SPEED_NORMAL
		var o = n.unit_offset + d * delta# * dir
		if o > 1 or o < 0:
			o = wrapf(o, 0, 1)
			if dead:
				n.hide()
			else:
				set_random_number(n.get_node("Label"))
		n.unit_offset = o

func _physics_process(delta):
	if dead: return
	if charging:
		position.x += CHARGE_SPEED * dir * delta
		if dir > 0 and (global_position.x > spawn_point.x + CHARGE_RANGE or global_position.x > target.global_position.x + 60):
			print("stopped1")
			charging = false
		elif dir < 0 and (global_position.x < spawn_point.x - CHARGE_RANGE or global_position.x < target.global_position.x - 60):
			print("stopped2")
			charging = false
	elif abs(spawn_point.x - global_position.x) > 60:
		dir = sign(spawn_point.x - global_position.x)
		position.x += RETURN_SPEED * dir * delta

func set_random_number(label):
	var x = N.rand_array(DIGITS)
	label.text = str(x)
	if x == 7:
		label.set("custom_colors/font_color", Color.red)
	else:
		label.set("custom_colors/font_color", default_color)

func _on_hit():
	var p = NUMBER_COUNT - ceil(NUMBER_COUNT * (health / max_health))
	for i in p:
		path.get_child(i).modulate = Color.magenta

func _on_die():
	modulate = Color(.7, .7, .7)
	R.play_sound("infinity_death", "Enemies")
	yield(get_tree().create_timer(2), "timeout")
	queue_free()

func charge():
	if target != null:
		charging = true
		dir = sign(target.global_position.x - global_position.x)
		R.play_sound("infinity_charge", "Enemies")

func _on_ChargeArea_body_entered(body):
	if dead: return
	target = body
	player_in_area = true
	if $ChargeTimer.is_stopped():
		charge()
		$ChargeTimer.start()

func _on_ChargeArea_body_exited(body):
	player_in_area = false

func _on_ChargeTimer_timeout():
	if dead: return
	if player_in_area:
		charge()
		$ChargeTimer.start()

func _on_DamageArea_body_entered(body):
	if dead: return
	body.apply_damage(damage)
	var v = Vector2(sign(body.global_position.x - global_position.x), -0.5).normalized()
	body.knockback(v * 300, 0.2)
