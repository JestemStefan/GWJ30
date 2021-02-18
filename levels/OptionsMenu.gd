extends Control


func _ready():
	var mouse_sensitivity_slider = $CenterContainer/VBoxContainer/HBoxContainer/CenterContainer/MouseSensitivitySlider
	mouse_sensitivity_slider.value = Globals.MOUSE_SENSITIVITY * 50.0	

func _on_HSlider_value_changed(value):
	Globals.MOUSE_SENSITIVITY = value / 50.0


func _on_CloseButton_pressed():
	get_tree().change_scene("res://levels/MainMenu.tscn")
