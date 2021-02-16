extends Spatial

func _ready():
	Globals.scene_root = self


func _input(event):
	if(event.is_action_pressed("ui_cancel")):
		var pause_menu = $CanvasLayer/CenterContainer/
		if pause_menu.is_visible_in_tree():
			pause_menu.hide()
			get_tree().paused = false
		
		else:
			pause_menu.show()			
			get_tree().paused = true
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
		
