extends Node2D

func _ready():
	$Base.scale.x = rand_range(0.8, 1.2)
	$Base.scale.y = rand_range(0.8, 1.5)
	#var orig = $ProjectileBlocker/CollisionShape2D.shape.extents
	#var new = orig * $Base.scale
	#$ProjectileBlocker/CollisionShape2D.shape.extents = new
	#$ProjectileBlocker.position.y -= (new.y - orig.y)
	for x in [["Base/Trunk","custom_colors/font_color"], ["Base/Trunk","custom_colors/font_outline_modulate"], ["Base/Top","custom_colors/font_color"], ["Base/Top","custom_colors/font_outline_modulate"]]:
		var n = x[0]
		var p = x[1]
		var c = get_node(n).get(p)
		c.r = clamp(c.r + rand_range(-0.1, 0.1), 0, 1)
		c.g = clamp(c.g + rand_range(-0.1, 0.1), 0, 1)
		c.b = clamp(c.b + rand_range(-0.1, 0.1), 0, 1)
		get_node(n).set(p, c)
