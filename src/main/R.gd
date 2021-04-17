extends Node

const CROSS_FADE_TIME = 3

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
const PrimeDenominator = preload("res://enemies/PrimeDenominator.tscn")
const LargeNumberBullet = preload("res://enemies/LargeNumberBullet.tscn")
const UpArrowBullet = preload("res://enemies/UpArrowBullet.tscn")
const PiBullet = preload("res://enemies/PiBullet.tscn")
const SevenLance = preload("res://enemies/SevenLance.tscn")
const SevenNine = preload("res://enemies/SevenNine.tscn")

# sounds
const Sounds = {
	
	"gun_switch": preload("res://sounds/weapswitch.ogg"),
	"out_of_ammo": preload("res://sounds/outofammo.ogg"),
	"decimal_fire": preload("res://sounds/shot_01.ogg"),
	"repeater_fire": preload("res://sounds/switch8.ogg"),
	"quadratic_fire": preload("res://sounds/dropLeather.ogg"),
	"quadratic_return": preload("res://sounds/footstep05.ogg"),
	"complex_fire": preload("res://sounds/minigun.ogg"),
	"dividezero_launch": preload("res://sounds/rlaunch.wav"),
	"dividezero_explosion": preload("res://sounds/explosion.ogg"),
	"dividezero_fizzle": preload("res://sounds/thwack-01.wav"),
	
	"player_hit": preload("res://sounds/wood_03.ogg"),
	"player_die": preload("res://sounds/PowerRez1.mp3"),
	"enemy_hit": preload("res://sounds/hit.ogg"),
	"loot_drop": preload("res://sounds/chain_03.ogg"),
	
	"fraction_shoot": preload("res://sounds/switch31.ogg"),
	"fraction_shoot2": preload("res://sounds/synth_laser_07.ogg"),
	"fraction_death": preload("res://sounds/Spell_01.wav"),
	
	"largenum_shoot": preload("res://sounds/click5.ogg"),
	"largenum_dive": preload("res://sounds/swish-9.wav"),
	"largenum_death": preload("res://sounds/Spell_01.wav"),
	
	"infinity_charge": preload("res://sounds/RezAlert1.mp3"),
	"infinity_death": preload("res://sounds/Spell_01.wav"),
	
	"pi_shoot": preload("res://sounds/switch30.ogg"),
	"pi_death": preload("res://sounds/Spell_01.wav"),
	
	"prime_spawn": preload("res://sounds/PowerUp26.ogg"),
	"prime_choose": preload("res://sounds/prime_choose.ogg"),
	"prime_shoot1": preload("res://sounds/click5.ogg"),
	"prime_shoot2": preload("res://sounds/synth_laser_03.ogg"),
	"prime_shoot3": preload("res://sounds/synth_misc_09.ogg"),
	"prime_die": preload("res://sounds/PowerDown1.mp3"),
	
	"graham_spawn": preload("res://sounds/Cyber-Chime2.mp3"),
	"graham_choose": preload("res://sounds/PowerUp30.mp3"),
	"graham_shoot1": preload("res://sounds/slimeball.wav"),
	"graham_shoot2": preload("res://sounds/synth_misc_09.ogg"),
	"graham_shoot3": preload("res://sounds/synth_misc_15.ogg"),
	"graham_die": preload("res://sounds/synth_misc_16.ogg"),
	
	"seven_spawn": preload("res://sounds/seven_spawn.ogg"),
	"seven_lance": preload("res://sounds/slimeball.wav"),
	"seven_spin": preload("res://sounds/PsychoCopter.ogg"),
	"seven_strafe": preload("res://sounds/seven_strafe.ogg"),
	"seven_nine": preload("res://sounds/Robot-Footstep_6.mp3"),
	"seven_die": preload("res://sounds/PowerDown3.mp3"),
}

const Music = {
	"menu": preload("res://music/Pixel-Quirk.mp3"),
	"game": preload("res://music/Arcade-Drama.mp3"),
	"boss": preload("res://music/Caffeine-Crazed-Coin-Op-Kids.mp3")
}

var _sfx = []
var _music = []
var _music_current = -1
var _tween = Tween.new()

func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS
	add_child(_tween)
	for i in 10:
		var a = AudioStreamPlayer.new()
		add_child(a)
		_sfx.append(a)
	for i in 2:
		var a = AudioStreamPlayer.new()
		a.bus = "Music"
		add_child(a)
		_music.append(a)
		

func play_sound(sound, bus = "SFX", volume = 1.0):
	for a in _sfx:
		if not a.playing:
			a.volume_db = linear2db(volume)
			a.bus = bus
			a.stream = Sounds[sound]
			a.play()
			return

func play_music(song, volume = 0.75, no_fade = false):
	var current = null if _music_current < 0 else _music[_music_current]
	var avail = _music[0 if _music_current != 0 else 1]
	var _music_new = 0 if _music_current != 0 else 1
	avail.stop()
	avail.stream = Music[song]
	if no_fade:
		avail.volume_db = linear2db(volume)
	else:
		avail.volume_db = linear2db(0)
		_tween.interpolate_method(self, "_fade_" + str(_music_new), 0, 1, CROSS_FADE_TIME)
	avail.play()
	if current != null:
		_tween.interpolate_method(self, "_fade_" + str(_music_current), db2linear(current.volume_db), 0, CROSS_FADE_TIME)
	_tween.start()
	_music_current = _music_new
	if current != null:
		yield(get_tree().create_timer(CROSS_FADE_TIME), "timeout")
		current.stop()
	
func stop_music():
	var current = null if _music_current < 0 else _music[_music_current]
	if current != null:
		_music_current = -1
		_tween.interpolate_property(current, "volume_db", 0, -80, 1)
		_tween.start()
		yield(get_tree().create_timer(1), "timeout")
		current.stop()
		
func _fade_0(v):
	_music[0].volume_db = linear2db(v)
func _fade_1(v):
	_music[1].volume_db = linear2db(v)
	
	
	
