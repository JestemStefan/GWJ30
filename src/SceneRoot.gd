extends Spatial

var main_theme = preload("res://raw_assets/audio/transfusion_bloodshed.ogg")
var gameover_theme = preload("res://raw_assets/audio/transfusion_gameover_ogg.ogg")

func _ready():
	play_main_theme()
	Globals.scene_root = self
	Engine.time_scale = 1.0

func play_main_theme():
	$AudioStreamPlayer.stream = main_theme
	$AudioStreamPlayer.play()

func play_gameover():
	$AudioStreamPlayer.stream = gameover_theme
	$AudioStreamPlayer.play()
