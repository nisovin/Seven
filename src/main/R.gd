extends Node

# guns
const Decimal = preload("res://guns/Decimal.tscn")
const DecimalBullet = preload("res://guns/DecimalBullet.tscn")
const Repeater = preload("res://guns/Repeater.tscn")
const RepeaterBullet = preload("res://guns/RepeaterBullet.tscn")
const Quadratic = preload("res://guns/Quadratic.tscn")
const Parabola = preload("res://guns/Parabola.tscn")
const RayGun = preload("res://guns/RayGun.tscn")
const Complex = preload("res://guns/Complex.tscn")
const ComplexBullet = preload("res://guns/ComplexBullet.tscn")
const DivideZero = preload("res://guns/DivideZero.tscn")
const DivideZeroRocket = preload("res://guns/DivideZeroRocket.tscn")

# level
const LootDrop = preload("res://level/LootDrop.tscn")

# enemies
const FractionBullet = preload("res://enemies/FractionBullet.tscn")
const FractionLance = preload("res://enemies/FractionLance.tscn")

# sounds
const Sounds = {
	
	"gun_switch": preload("res://sounds/weapswitch.ogg"),
	"decimal_fire": preload("res://sounds/shot_01.ogg"),
	"repeater_fire": preload("res://sounds/switch8.ogg"),
	"quadratic_fire": preload("res://sounds/dropLeather.ogg"),
	"quadratic_return": preload("res://sounds/footstep05.ogg"),
	"complex_fire": preload("res://sounds/minigun.ogg"),
	"dividezero_launch": preload("res://sounds/rlaunch.wav"),
	"dividezero_explosion": preload("res://sounds/explosion.ogg"),
	"dividezero_fizzle": preload("res://sounds/thwack-01.wav"),
	
	"player_hit": preload("res://sounds/wood_03.ogg"),
	"enemy_hit": preload("res://sounds/hit.ogg"),
	"fraction_death": preload("res://sounds/Spell_01.wav"),
	"loot_drop": preload("res://sounds/chain_03.ogg")
}

var _sfx_node

func _ready():
	_sfx_node = Node.new()
	_sfx_node.name = "SFX"
	add_child(_sfx_node)
	for i in 10:
		_sfx_node.add_child(AudioStreamPlayer.new())
		

func play_sound(sound, bus = "SFX", volume = 1.0):
	for a in _sfx_node.get_children():
		if not a.playing:
			a.volume_db = linear2db(volume)
			a.bus = bus
			a.stream = Sounds[sound]
			a.play()
			return
