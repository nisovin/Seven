extends Node2D

var player = null

func _ready():
	if $Item.get_child_count() == 0:
		generate(1)
	if not Game.first_loot_dropped:
		$FirstLoot.show()
		Game.first_loot_dropped = true

func generate(lvl, options = []):
	var drop_table = [R.Decimal, R.Repeater, R.Quadratic, R.RayGun, R.DivideZero]
	drop_table.erase(Game.last_gun_drop)
	var choice = N.rand_array(drop_table)
	Game.last_gun_drop = choice
	var item = choice.instance()
	item.generate(lvl)
	$Item.add_child(item)
	$AnimationPlayer.play("float")
	$Particles2D.emitting = true

func _on_PickupArea_body_entered(body):
	player = body
	$Help.visible = true

func _on_PickupArea_body_exited(body):
	player = null
	$Help.visible = false

func _unhandled_key_input(event):
	if player != null and not player.in_menu and event.is_action_pressed("interact"):
		player.current_gun.stop()
		var item = $Item.get_child(0)
		$Item.remove_child(item)
		player.loot(item)
		queue_free()
