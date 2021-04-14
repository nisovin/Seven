extends Position2D

export(NodePath) var entrance_door
export(NodePath) var exit_door

var fight_active = false
var boss_dead = false
var player

func _ready():
	$StartZone.connect("body_entered", self, "_on_startzone_entered")
	
func start_fight(p):
	player = p
	fight_active = true
	get_node(entrance_door).show()
	player.freeze_camera_target = true
	player.camera_target = global_position
	player.connect("died", self, "_on_player_died", [], CONNECT_ONESHOT)
	var boss = R.PrimeDenominator.instance()
	add_child(boss)
	boss.owner = owner
	boss.global_position = $BossSpawnPoint.global_position
	boss.spawn(player)
	boss.connect("died", self, "_on_boss_died", [], CONNECT_ONESHOT)

func end_fight(win):
	if fight_active:
		fight_active = false
		player.freeze_camera_target = false
		get_node(entrance_door).hide()
		if win:
			boss_dead = true
			get_node(exit_door).hide()

func _on_startzone_entered(body):
	if not fight_active and not boss_dead:
		fight_active = true
		call_deferred("start_fight", body)
	
func _on_boss_died():
	end_fight(true)
	
func _on_player_died():
	end_fight(false)
