extends Node2D

var gun_name = "Uninitialized Gun"
var short_name = "????"
var flavor_text = "This is some flavor text"
var level = 0
var base_damage = 10
var stats = {
	"addition": 0,
	"multiplication": 0,
	"subtraction": 0,
	"division": 0
}
var equipped = false
var active = false
var is_actively_firing = false

func generate(lvl):
	level = lvl
	if lvl == 0:
		base_damage = 10
		stats.addition = 1
		stats.division = 1
	else:
		base_damage = 10 + 5 * level + N.randi_range(0, 5)
		var alloc = lvl * 5 + N.randi_range(-1, 1)
		var stat_options = stats.keys()
		while alloc > 0:
			var s = N.rand_array(stat_options)
			stat_options.erase(s)
			var v = 1
			if stat_options.size() == 1:
				v = alloc
			elif alloc > 1:
				v = N.randi_range(1, alloc)
			stats[s] = v
			alloc -= v

func get_rich_text(flavor = false):
	var text = "[code][color=yellow]" + gun_name + "[/color]\nLevel " + str(level) + "[/code]\n"
	text += "[b][color=aqua]" + str(base_damage) + "[/color][/b] Damage"
	for stat in stats:
		if stats[stat] > 0:
			text += "\n[color=lime][b]+" + str(stats[stat]) + "[/b][/color] " + stat.capitalize()
	if flavor and flavor_text != "":
		text += "\n[color=gray]" + flavor_text + "[/color]"
	return text

func fire():
	pass

func stop():
	pass
