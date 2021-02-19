extends Control
onready var screen_settings_option_button = $CenterContainer/VBoxContainer/ScreenSettingsContainer/CenterContainer/ScreenSettingsOptionButton


func _ready():
	var mouse_sensitivity_slider = $CenterContainer/VBoxContainer/HBoxContainer/CenterContainer/MouseSensitivitySlider
	mouse_sensitivity_slider.value = Globals.MOUSE_SENSITIVITY * 50.0	
	
	for item in Globals.SCREEN_SETTINGS:
		screen_settings_option_button.add_item(item)
	
	screen_settings_option_button.select(Globals.SCREEN_SETTINGS.find(Globals.SCREEN_SETTING))
	
	#OS.window_borderless = true
	#OS.window_fullscreen = true
	

func _on_HSlider_value_changed(value):
	Globals.MOUSE_SENSITIVITY = value / 50.0


func _on_CloseButton_pressed():
	get_tree().change_scene("res://levels/MainMenu.tscn")


func _on_ScreenSettingsOptionButton_item_selected(index):
	Globals.SCREEN_SETTING = Globals.SCREEN_SETTINGS[index]
	match Globals.SCREEN_SETTINGS[index]:
		"Full Screen Windowed":
			OS.window_fullscreen = true
			OS.window_borderless = false
		"Full Screen":
			OS.window_fullscreen = true
			OS.window_borderless = true
		"Windowed":
			OS.window_fullscreen = false
			OS.window_borderless = false
		
