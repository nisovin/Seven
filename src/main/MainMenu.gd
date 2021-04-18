extends Control

onready var menu = $Menu
onready var number_box = $Menu/VBoxContainer/Number
onready var intro = $Intro
onready var story_text = $Intro/VBoxContainer2/StoryText
onready var continue_label = $Intro/VBoxContainer2/ContinueLabel
onready var tween = $Tween
onready var timer = $Intro/Timer

var regex = RegEx.new()
var menu_closed = false
var doing_story = false
var next_para = 0

func _ready():
	var n = N.randi_range(100, 999)
	number_box.text = str(n).replace("7", "3")
	number_box.grab_focus()
	number_box.caret_position = 3
	regex.compile("[^123456890]")
	R.play_music("menu", 0.25, true)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_Number_text_changed(new_text):
	var t = regex.sub(new_text, "", true)
	if t != new_text:
		new_text = t
		number_box.text = new_text
		number_box.caret_position = new_text.length()
	$Menu/VBoxContainer/PlayButton.disabled = new_text.length() != 3

func play(t = ""):
	if menu_closed: return
	Game.number = number_box.text
	menu_closed = true
	if Settings.video_fullscreen:
		OS.window_fullscreen = true
	R.play_sound("button_click", "SFX")
	show_story()

func show_story():
	for c in story_text.get_children():
		c.bbcode_text = c.bbcode_text.replace("NUMBER", Game.number)
		c.percent_visible = 0
		c.hide()
	continue_label.modulate = Color.transparent
	tween.interpolate_property(menu, "modulate", Color.white, Color.transparent, 1)
	tween.start()
	intro.show()
	yield(get_tree().create_timer(1.3), "timeout")
	show_next_para()
	doing_story = true

func show_next_para():
	if next_para > 0:
		story_text.get_child(next_para - 1).percent_visible = 1
	tween.remove_all()
	var p = story_text.get_child(next_para)
	p.show()
	continue_label.modulate = Color.transparent
	tween.interpolate_property(p, "percent_visible", 0, 1, 2)
	tween.interpolate_property(continue_label, "modulate", Color.transparent, Color.white, 1, Tween.TRANS_LINEAR, Tween.EASE_IN, 2.1)
	tween.start()
	next_para += 1

func _on_Timer_timeout():
	pass # Replace with function body.
	
func _input(event):
	if doing_story:
		if (event is InputEventKey or event is InputEventMouseButton or event is InputEventJoypadButton) and event.pressed:
			if next_para >= story_text.get_child_count() or event.is_action_pressed("ui_cancel"):
				tween.interpolate_property(intro, "modulate", Color.white, Color.transparent, 1)
				tween.start()
				yield(get_tree().create_timer(1), "timeout")
				R.load_audio()
				get_tree().change_scene("res://level/Level.tscn")
			else:
				show_next_para()

func _on_button_mouse_entered():
	R.play_sound("button_rollover", "SFX", 0.2)
	
func _on_SettingsButton_pressed():
	R.play_sound("button_click", "SFX")
	Settings.show_menu()

func _on_CreditsButton_pressed():
	R.play_sound("button_click", "SFX")
	$Credits.popup_centered()

func _on_CreditsBox_meta_clicked(meta):
	OS.shell_open(meta)
	
func _on_CloseCreditsButton_pressed():
	$Credits.hide()
	
func _on_QuitButton_pressed():
	get_tree().quit()






