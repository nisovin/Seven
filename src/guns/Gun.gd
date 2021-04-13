extends Node2D

var level = 0
var base_damage = 1
var stats = {
	"addition": 0,
	"multiplication": 0,
	"subtraction": 0,
	"division": 0
}
var is_actively_firing = false

func generate(lvl):
	level = lvl
	if lvl == 0:
		base_damage = 10
		stats.addition = 2
	else:
		base_damage = level * 15 + N.randi_range(0, 10)

func fire():
	pass

func stop():
	pass
