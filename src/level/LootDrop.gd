extends Node2D

var player = null

func _ready():
	if $Item.get_child_count() == 0:
		generate(1)
	if not Game.first_loot_dropped:
		$FirstLoot.show()
		Game.first_loot_dropped = true

func generate(lvl, options = []):
	var drop_table = {}
	if not "devices_only" in options:
		if not "no_decimal" in options:
			drop_table[R.Decimal] = 4
		drop_table[R.Repeater] = 10
		drop_table[R.Quadratic] = 8
		drop_table[R.Complex] = 10
		drop_table[R.RayGun] = 10
		drop_table[R.DivideZero] = 5
	var choice = N.rand_weighted(drop_table)
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
		var item = $Item.get_child(0)
		$Item.remove_child(item)
		player.loot(item)
		queue_free()
