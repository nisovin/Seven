extends Control

onready var loot_screen = $LootScreen
onready var char_screen = $CharacterSheet

var player = null
var pending_new_gun = null

func open_character_sheet():
	var guns = player.get_guns()
	for i in guns.size():
		if guns[i] != null:
			char_screen.find_node("Gun" + str(i+1)).bbcode_text = guns[i].get_rich_text()
		else:
			char_screen.find_node("Gun" + str(i+1)).bbcode_text = "[b]Empty Slot[/b]"
	player.update_stats()
	for stat in player.stats:
		char_screen.find_node("Stat" + stat.capitalize()).text = str(player.stats[stat])
		char_screen.find_node("Stat" + stat.capitalize()).hint_tooltip = call("tooltip_stat_" + stat, player.stats[stat])
		char_screen.find_node("Label" + stat.capitalize()).hint_tooltip = call("tooltip_stat_" + stat, player.stats[stat])
	char_screen.popup_centered()
	player.in_menu = true
	get_tree().paused = true

func _on_CloseButton_pressed():
	char_screen.hide()
	
func _on_CharacterSheet_popup_hide():
	get_tree().paused = false
	player.in_menu = false

func _unhandled_input(event):
	if event.is_action_pressed("open_char_sheet") and char_screen.visible:
		char_screen.call_deferred("hide")

func open_loot_screen(new_gun):
	pending_new_gun = new_gun
	loot_screen.find_node("NewGun").bbcode_text = new_gun.get_rich_text()
	var guns = player.get_guns()
	for i in guns.size():
		if guns[i] != null:
			loot_screen.find_node("CurrentGun" + str(i+1)).bbcode_text = guns[i].get_rich_text()
			loot_screen.find_node("EquipButton" + str(i+1)).text = "Replace"
		else:
			loot_screen.find_node("CurrentGun" + str(i+1)).bbcode_text = "[b]Empty Slot[/b]"
			loot_screen.find_node("EquipButton" + str(i+1)).text = "Equip"
	loot_screen.popup_centered()
	player.in_menu = true
	get_tree().paused = true

func _on_LootScreen_popup_hide():
	pending_new_gun = null
	get_tree().paused = false
	player.in_menu = false

func _on_DiscardButton_pressed():
	loot_screen.hide()

func _on_EquipButton_pressed(slot):
	player.equip_gun(pending_new_gun, slot)
	loot_screen.hide()

func tooltip_stat_addition(s):
	return "Adds %s damage to attacks" % s
func tooltip_stat_multiplication(s):
	return "Gives %s%% chance to deal double damage" % (s * 2)
func tooltip_stat_subtraction(s):
	return "Reduces incoming damage by %s" % s
func tooltip_stat_division(s):
	return "Gives %s%% percent chance to cut incoming damage by half" % (s * 2)
