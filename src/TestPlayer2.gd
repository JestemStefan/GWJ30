extends KinematicBody

onready var gimbal_x = $GimbalX 			# vertical gimbal (looking up and down)
onready var gimbal_y = $GimbalX/GimbalY		# horizontal gimbal (left and right)


func _ready():
	# Capture mouse movement
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# check inputs like mouse movement or key pressing
func _input(event):
	# if mouse is moving and we are capturing mouse movement
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		
		# rotate up and down
		gimbal_x.rotate_y(deg2rad(-event.relative.x * 0.2))
		# rotate left and right
		gimbal_y.rotate_x(deg2rad(-event.relative.y * 0.2))
		
		# limit camera angle so you can't look straight up or upside down
		gimbal_y.rotation_degrees.x = clamp(gimbal_y.rotation_degrees.x, -75, 20)
