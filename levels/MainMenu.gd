extends Control

func _ready():
	Engine.time_scale = 1.0
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_ExitButton_pressed():
	get_tree().quit()

func _on_PlayButton_pressed():
	get_tree().change_scene("res://levels/Arena.tscn")

func _on_OptionsButton_pressed():
	$Options.visible = true

func _on_HowToPlayButton_pressed():
	$HowToPlay.visible = true
