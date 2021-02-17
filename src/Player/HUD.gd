extends CanvasLayer

func _ready():
	OS.set_window_position(Vector2(OS.window_position.x + 440, OS.window_position.y))
	pass

func _process(_delta):
	$Root/FPSCounter.text = str(Engine.get_frames_per_second()) + " FPS"
	# Toggle mouse mode
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE) # Free the mouse
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func set_heart_rate(val: float):
	$Root/HeartRateContainer/BarContainer/HeartRateBar.value = val

func heartbeat():
	$Root/CrosshairAnimation.stop(true)
	$Root/CrosshairAnimation.play("Heartbeat")

func damage():
	$Root/VignetteAnimation.stop(true)
	$Root/VignetteAnimation.play("Damage")

func game_over():
	$Root/GameOver.visible = true
	Utils.do_hitstop(0.25)
	yield(get_tree().create_timer(1.0), "timeout")
	get_tree().change_scene("res://levels/MainMenu.tscn")
