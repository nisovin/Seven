extends KinematicBody2D

const JUMP_POWER = 750
const GRAVITY = 1800
const SPEED = 250
const MAX_FALL_SPEED = 900
const MAX_GUN_ROT = PI / 4

var target_position setget , get_target_position

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
var in_menu = false

var max_health = 100.0
var health = max_health

var stats = {
	"addition": 0,
	"multiplication": 0,
	"subtraction": 0,
	"division": 0,
}

var current_gun = null

onready var camera = $Camera2D
onready var ground_finders = $GroundFinder.get_children()

func _ready():
	camera.set_as_toplevel(true)
	camera.global_position = global_position
	switch_weapon(0)
	current_gun.generate(0)
	$GUI/PlayerGUI.player = self
	update_stats()

func get_target_position():
	return $Position2D.global_position

func modify_damage(damage):
	var dam = damage + stats.addition
	var crit = stats.multiplication / 100.0 * 2
	if crit > 1:
		dam *= 1.5
		crit -= 1
	if N.randf() < crit:
		dam *= 1.5
	return dam
	
func apply_damage(damage, from = null):
	var dam = max(damage - stats.subtraction, 0)
	var crit = stats.division / 100.0 * 2
	if N.randf() < crit:
		dam *= 0.5
	health -= dam
	var pct = health / max_health
	if pct < .25:
		$Body/NumberFore.update_width(.2)
	elif pct < .50:
		$Body/NumberFore.update_width(.5)
	elif pct < .75:
		$Body/NumberFore.update_width(.7)
	else:
		$Body/NumberFore.update_width(1)
	
	R.play_sound("player_hit", "Player")
		
		
	print(health)

func knockback(vec, dur):
	knockback_vector = vec
	knockback_change = knockback_vector.length() / dur

func reset_down():
	if is_on_floor():
		global_position += up * 30
	global_rotation = 0
	up = Vector2.UP
	
func loot(item):
	$GUI/PlayerGUI.open_loot_screen(item)

func get_guns():
	var array = [null, null, null]
	for i in array.size():
		var n = $GunAttach.get_child(i)
		if n.get_child_count() == 1:
			array[i] = n.get_child(0)
	return array

func equip_gun(gun, slot):
	var switch = false
	var slot_node = $GunAttach.get_child(slot)
	if slot_node.get_child_count() > 0:
		var old_gun = slot_node.get_child(0)
		if old_gun == current_gun:
			switch = true
		slot_node.remove_child(old_gun)
		$OldGuns.add_child(old_gun)
		old_gun.owner = self
		old_gun.equipped = false
	slot_node.add_child(gun)
	gun.owner = self
	gun.equipped = true
	if switch:
		switch_weapon(slot)
	update_stats()
	
func switch_weapon(slot):
	var slot_node = $GunAttach.get_child(slot)
	if slot_node.get_child_count() > 0:
		for child in $GunAttach.get_children():
			child.hide()
		if current_gun != null:
			current_gun.active = false
			current_gun.stop()
		slot_node.show()
		current_gun = slot_node.get_child(0)
		current_gun.active = true
		R.play_sound("gun_switch", "Player")
	

func update_stats():
	for stat in stats:
		stats[stat] = 0
	for n in $GunAttach.get_children():
		if n.get_child_count() == 1:
			var g = n.get_child(0)
			for stat in stats:
				if stat in g.stats:
					stats[stat] += g.stats[stat]

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
		reset_down()
	
	elif event.is_action_pressed("weapon_1"):
		switch_weapon(0)
	elif event.is_action_pressed("weapon_2"):
		switch_weapon(1)
	elif event.is_action_pressed("weapon_3"):
		switch_weapon(2)
		
	elif event.is_action_pressed("open_char_sheet"):
		$GUI/PlayerGUI.open_character_sheet()
		

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

