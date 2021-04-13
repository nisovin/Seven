tool
extends Line2D

export var update_now = false setget update_line
export var hide_range = false
export var text_offset = Vector2.ZERO
export var one_way = false

func _ready():
	update_line(true)

func update_line(no):
	if points.size() != 2: return
	var v = points[1] - points[0]
	
	# find line equation
	var point1 = to_global(points[0]) / 60.0
	var point2 = to_global(points[1]) / 60.0
	if point1.x == point2.x:
		$Equation/Label.text = "x = " + str(stepify(point1.x, 0.05))
		if not hide_range:
			$Equation/Label.text += " ;   " + str(stepify(point1.y, 0.05)) + " <= y <= " + str(stepify(point2.y, 0.05))
	else:
		var slope = (-point2.y - -point1.y) / (point2.x - point1.x)
		var intercept = -point1.y - point1.x * slope
		$Equation/Label.text = "y = "
		if slope != 0:
			$Equation/Label.text += str(stepify(slope, 0.05)) + "x " + ("+" if sign(intercept) >= 0 else "-") + " "
		elif intercept < 0:
			$Equation/Label.text += "-"
		$Equation/Label.text += str(abs(stepify(intercept, 0.05)))
		if not hide_range:
			$Equation/Label.text += " ;   " + str(stepify(point1.x, 0.05)) + " <= x <= " + str(stepify(point2.x, 0.05))
	
	# set label position
	$Equation/Label.rect_position = points[0] + (Vector2(width, width / 2 + 2) + text_offset).rotated(v.angle())
	$Equation/Label.rect_rotation = rad2deg(v.angle())
	
	# set collision shape
	$LineBody.position = (points[0] + points[1]) / 2
	$LineBody.rotation = v.angle()
	$LineBody/CollisionShape2D.shape.extents = Vector2(v.length() / 2, width / 2)
