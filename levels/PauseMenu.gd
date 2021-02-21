extends Control

func _input(event):
	if(event.is_action_pressed("ui_cancel")):
		var pause_menu = self
		if pause_menu.is_visible_in_tree():
			pause_menu.hide()
			get_tree().paused = false
		else:
			pause_menu.show()
			get_tree().paused = true
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_ExitButton_pressed():
	get_tree().paused = false
	get_tree().change_scene("res://levels/MainMenu.tscn")

func _on_OptionsButton_pressed():
	$Options.visible = true
