extends Control

onready var menu = $Menu
onready var number_box = $Menu/VBoxContainer/Number
onready var intro = $Intro
onready var story_text = $Intro/VBoxContainer2/StoryText
onready var continue_label = $Intro/VBoxContainer2/ContinueLabel

var regex = RegEx.new()

func _ready():
	var n = N.randi_range(100, 999)
	number_box.text = str(n).replace("7", "3")
	number_box.grab_focus()
	number_box.caret_position = 3
	regex.compile("[^123456890]")

func _on_Number_text_changed(new_text):
	var t = regex.sub(new_text, "", true)
	if t != new_text:
		new_text = t
		number_box.text = new_text
		number_box.caret_position = new_text.length()
	$Menu/VBoxContainer/PlayButton.disabled = new_text.length() != 3

func play(t = ""):
	Game.number = number_box.text
	get_tree().change_scene("res://level/Level.tscn")
