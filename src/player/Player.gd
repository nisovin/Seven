extends KinematicBody2D

const JUMP_POWER = 750
const GRAVITY = 1800
const SPEED = 250
const MAX_FALL_SPEED = 1000
const MAX_GUN_ROT = PI / 4

var walk_anim_legs = ["/ \\", "/\\", "/|", "||", "|\\", "/\\"]
var walk_anim_body_offset = [0, -1, -3, -4, -3, -1]
var walk_anim_frame = 0
var fly_anim_legs = ["/|", "|\\"]
var fly_anim_frame = 0

var number = 800

var velocity = Vector2.ZERO
var knockback_vector = Vector2.ZERO
var knockback_change = 0
var camera_target = position
var up = Vector2.UP
var near_ground = false
var jumps = 1
var jump_cd = 0
var speed_multiplier = 1.0
var freeze_aiming = false

var health = 100

var stats = {
	"addition": 0,
	"multiplication": 0,
	"subtraction": 0,
	"division": 0,
}

onready var current_gun = $GunAttach/Decimal

onready var camera = $Camera2D
onready var ground_finders = $GroundFinder.get_children()

func _ready():
	camera.set_as_toplevel(true)
	camera.global_position = global_position

func modify_damage(damage):
	var dam = damage + stats.addition
	var crit = stats.multiplication / 100.0 * 2
	if crit > 1:
		dam *= 1.5
		crit -= 1
	if N.randf() < crit:
		dam *= 1.5
	return dam
	
func apply_damage(damage, from):
	var dam = max(damage - stats.subtraction, 0)
	var crit = stats.division / 100.0 * 2
	if N.randf() < crit:
		dam *= 0.5
	health -= dam

func knockback(vec, dur):
	knockback_vector = vec
	knockback_change = knockback_vector.length() / dur

func _process(delta):
	camera_target = global_position + (get_global_mouse_position() - global_position) * 0.35
	camera.global_position = lerp(camera.global_position, camera_target, delta * 4)

func _physics_process(delta):
	
	if speed_multiplier > 0:
		
		var new_up = Vector2.ZERO
		var count = 0
		for ray in ground_finders:
			if ray.is_colliding():
				count += 1
				new_up += ray.get_collision_normal()
		if count > 0:
			up = new_up / count
		near_ground = count > 0
		if is_on_floor():
			global_rotation = Vector2.UP.angle_to(up)
			if jumps == 0:
				jumps = 1
		
		if Input.is_action_pressed("jump") and jumps > 0 and is_on_floor():
			velocity.y = -JUMP_POWER * speed_multiplier
			jumps -= 1
		elif Input.is_action_just_pressed("jump") and jumps > 0:
			velocity.y = -JUMP_POWER * speed_multiplier
			jumps -= 1
		
		var move = Input.get_action_strength("right") - Input.get_action_strength("left")
		velocity.x = move * SPEED * speed_multiplier
		#if not is_on_floor():
		#	velocity.x *= 0.6
		velocity.y = min(velocity.y + GRAVITY * delta, MAX_FALL_SPEED)
		var v = velocity.rotated(global_rotation)
		if knockback_vector != Vector2.ZERO:
			v += knockback_vector
			knockback_vector = knockback_vector.move_toward(Vector2.ZERO, knockback_change * delta)
		v = move_and_slide_with_snap(v, -up * 3 if velocity.y >= 0 else Vector2.ZERO, up)
		velocity.y = v.rotated(-global_rotation).y
			
	
	if not freeze_aiming:
		$GunAttach.look_at(get_global_mouse_position())
		var rot = wrapf($GunAttach.rotation, -PI, PI)
		if $GunAttach.transform.x.x >= 0:
			if rot > MAX_GUN_ROT:
				$GunAttach.rotation = MAX_GUN_ROT
			elif rot < -MAX_GUN_ROT:
				$GunAttach.rotation = -MAX_GUN_ROT
		else:
			if rot < PI - MAX_GUN_ROT and rot > 0:
				$GunAttach.rotation = PI - MAX_GUN_ROT
			elif rot > -PI + MAX_GUN_ROT and rot < 0:
				$GunAttach.rotation = -PI + MAX_GUN_ROT

func _unhandled_input(event):
	if event.is_action_pressed("fire"):
		current_gun.fire()
	elif event.is_action_released("fire"):
		current_gun.stop()
	elif event.is_action_pressed("down") and not is_on_floor():
		global_rotation = 0
	
	if event is InputEventKey and event.pressed:
		var g = -1
		if event.scancode == KEY_1:
			g = 0
		if event.scancode == KEY_2:
			g = 1
		if event.scancode == KEY_3:
			g = 2
		if event.scancode == KEY_4:
			g = 3
		if event.scancode == KEY_5:
			g = 4
		if event.scancode == KEY_6:
			g = 5
		if g >= 0:
			for n in $GunAttach.get_children():
				n.visible = false
			current_gun = $GunAttach.get_child(g)
			current_gun.visible = true

func _on_WalkAnimTimer_timeout():
	if is_on_floor():
		if abs(velocity.x) > 5:
			var dir = -1 if velocity.x < 0 else 1
			walk_anim_frame = wrapi(walk_anim_frame + dir, 0, walk_anim_legs.size())
		else:
			walk_anim_frame = 0
		$Legs/Label.text = walk_anim_legs[walk_anim_frame]
		$Body.position.y = walk_anim_body_offset[walk_anim_frame]
	else:
		fly_anim_frame = wrapi(fly_anim_frame + 1, 0, fly_anim_legs.size())
		$Legs/Label.text = fly_anim_legs[fly_anim_frame]
		$Body.position.y = 0

