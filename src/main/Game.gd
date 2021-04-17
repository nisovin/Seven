extends Node

var number = "800"
var first_loot_dropped = false
var last_gun_drop = R.Decimal

func _ready():
	Settings.connect("setting_changed", self, "_on_setting_changed")
	if Settings.video_fullscreen:
		OS.window_fullscreen = true
	
func _on_setting_changed(setting, new_value):
	if setting == "video_fullscreen":
		OS.window_fullscreen = new_value
