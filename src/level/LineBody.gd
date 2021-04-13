extends StaticBody2D

func toggle_one_way(enable):
	if owner.one_way:
		$CollisionShape2D.set_deferred("disabled", enable)
		print("DISABLE ", enable)
