extends CenterContainer


func _on_ExitButton_pressed():
	get_tree().paused = false
	get_tree().change_scene("res://levels/MainMenu.tscn")
