extends Position2D

export(NodePath) var entrance_door
export(NodePath) var exit_door

var fight_active = false
var boss_dead = false
var player = null
var boss = null

func _ready():
	$StartZone.connect("body_entered", self, "_on_startzone_entered")
	
func start_fight(p):
	player = p
	fight_active = true
	get_node(entrance_door).show()
	player.no_heal = true
	player.freeze_camera_target = true
	player.camera_target = global_position
	player.connect("died", self, "_on_player_died", [], CONNECT_ONESHOT)
	if boss != null:
		boss.queue_free()
	boss = R.PrimeDenominator.instance()
	add_child(boss)
	boss.owner = owner
	boss.global_position = $BossSpawnPoint.global_position
	boss.spawn(player)
	boss.connect("died", self, "_on_boss_died", [], CONNECT_ONESHOT)
