extends Node

var rng = RandomNumberGenerator.new()

func _ready():
	randomize()
	rng.randomize()

func randf():
	return rng.randf()

func randf_range(vmin, vmax):
	return rng.randf_range(vmin, vmax)
	
func randi_range(vmin, vmax):
	return rng.randi_range(vmin, vmax)

func rand_array(array):
	return array[rng.randi_range(0, array.size() - 1)]

func rand_weighted(options):
	var total_weight = 0
	for option in options:
		total_weight += options[option]
	var rand = randf_range(0, total_weight)
	for option in options:
		rand -= options[option]
		if rand < 0:
			return option
	return options.keys()[0]
