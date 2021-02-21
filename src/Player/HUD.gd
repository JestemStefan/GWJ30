extends CanvasLayer

func _ready():
	#OS.set_window_position(Vector2(OS.window_position.x + 440, OS.window_position.y))
	pass

func _process(_delta):
	#$Root/FPSCounter.text = str(Engine.get_frames_per_second()) + " FPS"
	# Toggle mouse mode
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE) # Free the mouse
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func set_heart_rate(val: float):
	$Root/ResourcesContainer/HeartRateContainer/BarContainer/HeartRateBar.value = val

func set_blood(val: int):
	$Root/ResourcesContainer/BloodContainer/BloodCount.text = str(val)

func heartbeat():
	$Root/CrosshairAnimation.stop(true)
	$Root/CrosshairAnimation.play("Heartbeat")
	pass

func damage():
	$Root/VignetteAnimation.stop(true)
	$Root/VignetteAnimation.play("Damage")

func game_over():
	$Root/GameOver.visible = true
	#$GameOverTimer.start(0.2)
	if $GameOverTimer.is_stopped():
		Engine.time_scale = 0.1
		$GameOverTimer.paused = false
		$GameOverTimer.start(0.75)

func game_won():
	$Root/YouWon.visible = true
	#$GameOverTimer.start(0.2)
	if $YouWonTimer.is_stopped():
		Engine.time_scale = 0.1
		$YouWonTimer.paused = false
		$YouWonTimer.start(0.75)

func set_crosshair(num: int):
	for n in range(3):
		var crosshair = $Root/CenterContainer/CrosshairContainer.get_child(n)
		if n == num:
			crosshair.visible = true
		else:
			crosshair.visible = false

func _on_GameOverTimer_timeout():
	Engine.time_scale = 1.0
	get_tree().change_scene("res://levels/MainMenu.tscn")


func _on_YouWonTimer_timeout():
	Engine.time_scale = 1.0
	get_tree().change_scene("res://levels/MainMenu.tscn")

func set_heart_dist(val):
	var prop = 256 - (val * 192)
	$Root/CenterContainer/ClickIndicatorOuter.rect_min_size = Vector2(prop,prop)
