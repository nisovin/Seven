extends "Enemy.gd"

const NUMBER_COUNT = 20
const NUMBER_SPEED_NORMAL = 0.2
const NUMBER_SPEED_MOVING = 0.6
const NUMBER_SPEED_DEAD = 1.0
const DIGITS = [0, 1, 2, 3, 4, 5, 6, 7, 7, 7, 7, 8, 9]

const MOVE_ANIM_DUR = 1.0

export var charge_range = 300

onready var path = $Mover/Path2D

var default_color
var dir = 1
var moving = false

func _ready():
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
		if moving:
			d = NUMBER_SPEED_MOVING
		elif dead:
			d = NUMBER_SPEED_DEAD
		else:
			d = NUMBER_SPEED_NORMAL
		var o = n.unit_offset + d * delta * dir
		if o > 1 or o < 0:
			o = wrapf(o, 0, 1)
			if dead:
				n.hide()
			else:
				set_random_number(n.get_node("Label"))
		n.unit_offset = o

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
	yield(get_tree().create_timer(2), "timeout")
	queue_free()

func move(dir):
	$Tween.interpolate_property($Mover, "position:y", 0, -25, MOVE_ANIM_DUR / 2.0)
	$Tween.interpolate_property($Mover, "position:y", -25, 0, MOVE_ANIM_DUR / 2.0, Tween.TRANS_LINEAR, Tween.EASE_IN, MOVE_ANIM_DUR / 2.0)
	$Tween.interpolate_property($Mover, "rotation", $Mover.rotation, $Mover.rotation + dir * PI, MOVE_ANIM_DUR)
	$Tween.interpolate_property(self, "position:x", position.x, position.x + 50 * dir, MOVE_ANIM_DUR)
	$Tween.start()
