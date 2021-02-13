extends CanvasLayer

func _ready():
	pass

func _process(_delta):
	$Root/FPSCounter.text = str(Engine.get_frames_per_second()) + " FPS"
	# Toggle mouse mode
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE) # Free the mouse
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
