extends "Enemy.gd"

const REVOLVE_SPEED = -PI * 0.25
const ROTATE_SPEED = PI * 0.4

onready var outer = get_parent()

func _ready():
	owner = outer.owner
	var t = str(N.rand_array([1,2,3,4,5,6,8,9]))
	if N.randf() < 0.5:
		t = "[color=red]7[/color]" + t
	else:
		t += "[color=red]7[/color]"
	$Label.bbcode_text = "[center]" + t + "π[/center]"

func _physics_process(delta):
	if dead: return
	outer.rotation += REVOLVE_SPEED * PI * delta
	rotation += ROTATE_SPEED * PI * delta

func _on_hit():
	if health > 0:
		$Health.value = health / max_health
		
func _on_die():
	$AnimationPlayer.play("die")
	yield(get_tree().create_timer(1), "timeout")
	outer.queue_free()
