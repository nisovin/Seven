extends Position2D

export(PackedScene) var boss_scene
export(NodePath) var entrance_door = null
export(NodePath) var exit_door = null
export(NodePath) var spawn_parent = null
export(NodePath) var spawn_point = null
export(NodePath) var death_zone = null

var fight_active = false
var boss_dead = false
var player = null
var boss = null

func _ready():
	$StartZone.connect("body_entered", self, "_on_startzone_entered")
	
func start_fight(p):
	player = p
	fight_active = true
	if entrance_door != null:
		get_node(entrance_door).show()
	player.no_heal = true
	player.freeze_camera_target = true
	player.camera_target = global_position
	player.connect("died", self, "_on_player_died", [], CONNECT_ONESHOT)
	boss = boss_scene.instance()
	if spawn_parent != null:
		get_node(spawn_parent).add_child(boss)
	else:
		add_child(boss)
	boss.owner = owner
	if spawn_point != null:
		boss.global_position = get_node(spawn_point).global_position
	boss.spawn(player)
	boss.connect("died", self, "_on_boss_died", [], CONNECT_ONESHOT)
	if death_zone != null:
		get_node(death_zone).set_deferred("disabled", false)
	R.play_music("boss")

func end_fight(win):
	if fight_active:
		fight_active = false
		player.no_heal = false
		player.freeze_camera_target = false
		if entrance_door != null:
			get_node(entrance_door).hide()
		if win:
			boss_dead = true
			if exit_door != null:
				get_node(exit_door).hide()
		if death_zone != null:
			get_node(death_zone).set_deferred("disabled", true)
		var old_boss = boss
		yield(get_tree().create_timer(3), "timeout")
		R.play_music("game")
		if win:
			yield(get_tree().create_timer(7), "timeout")
		old_boss.queue_free()

func _on_startzone_entered(body):
	if not fight_active and not boss_dead and not body.dead:
		fight_active = true
		call_deferred("start_fight", body)
	
func _on_boss_died():
	end_fight(true)
	
func _on_player_died():
	end_fight(false)
