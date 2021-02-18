extends MarginContainer


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _on_ExitButton_pressed():
	get_tree().quit()


func _on_PlayButton_pressed():	
	get_tree().change_scene("res://levels/Sandbox1.tscn")


func _on_OptionsButton_pressed():
	get_tree().change_scene("res://levels/OptionsMenu.tscn")
