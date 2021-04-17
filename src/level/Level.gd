extends Node2D

const BACK_COLOR_CHANGE_SPEED = 20

onready var player = $Player

var default_bg = Color8(25, 25, 25)
var current_bg = default_bg
var old_bg = default_bg
var new_bg = default_bg

func _ready():
	R.play_music("game")

func fct(pos, dam, color):
	print(pos, dam, color)
	var fct = R.FCT.instance()
	$Loot.add_child(fct)
	fct.global_position = pos
	fct.init(str(ceil(dam)), color)

func spawn_loot(pos, level, options = []):
	var loot = R.LootDrop.instance()
	loot.generate(level)
	$Loot.add_child(loot)
	loot.global_position = pos
	R.play_sound("loot_drop", "Level")

func change_background_color(new_color):
	$BackgroundTween.remove_all()
	old_bg = current_bg
	if new_color == null:
		new_bg = default_bg
	else:
		new_bg = new_color
	$BackgroundTween.interpolate_method(self, "_set_background_color", 0, 1.0, 6)
	$BackgroundTween.start()
	
func _set_background_color(progress):
	current_bg = Color.from_hsv(lerp(old_bg.h, new_bg.h, progress),
			lerp(old_bg.s, new_bg.s, progress),
			lerp(old_bg.v, new_bg.v, progress))
	VisualServer.set_default_clear_color(current_bg)
	
func show_win():
	$Text/WinMessage.modulate = Color.transparent
	$Text/WinMessage.show()
	$Tween.interpolate_property($Text/WinMessage, "modulate", Color.transparent, Color.white, 2)
	$Tween.start()
