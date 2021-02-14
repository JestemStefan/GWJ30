extends Spatial

# Config
export var default_fov: float = 90
export var mouse_sensitivity: float = 0.075

# Utils
var intended_resolution: Vector2
var adjusted_mouse_sensitivity: Vector2
var space_state: PhysicsDirectSpaceState
var aim_position: Vector3
var third_person_offset: Vector3

# Effects
var cam_shake: float = 0.0
var desired_fov: float = 90.0
var first_person_offset: Vector3
var third_person: bool = true
var recoil: Vector2 = Vector2.ZERO

# Node assignments
onready var camera_yaw = self
onready var camera_pitch = $CameraPitch
onready var camera = $CameraPitch/Camera
onready var player = get_parent()

func _ready():
	# Setup for keeping constant mouse sensitivity
	var screen_width = ProjectSettings.get_setting("display/window/size/width")
	var screen_height = ProjectSettings.get_setting("display/window/size/height")
	intended_resolution = Vector2(screen_width, screen_height)
	# Set as default
	adjusted_mouse_sensitivity = Vector2(mouse_sensitivity, mouse_sensitivity)
	var _connection = get_viewport().connect("size_changed", self, "viewport_size_changed")
	# For raycasting
	space_state = get_world().get_direct_space_state()
	# Set third person offset to default camera position
	third_person_offset = camera.transform.origin

func _process(delta):
	# Smooth fov changes
	camera.fov = lerp(camera.fov, desired_fov, delta * 8)
	# Clamp up and down
	camera_pitch.rotation.x = clamp(camera_pitch.rotation.x, deg2rad(-70.0), deg2rad(60.0))

func _physics_process(delta):
	# Handle camera shake
	if cam_shake > 0.0:
		var cam_shake_offset = Vector3.LEFT.rotated(Vector3.FORWARD, rand_range(0.0, 2 * PI)) * cam_shake
		camera.translation = lerp(camera.translation, camera.translation + cam_shake_offset, 0.5)
		cam_shake -= delta/2
		if cam_shake <= 0.0:
			cam_shake = 0.0
	# Handle recoil
	(camera as Spatial).rotation_degrees.x = lerp(0.0, recoil.x, 0.3)
	(camera as Spatial).rotation_degrees.y = lerp(-180, -180 + recoil.y, 0.3)
	recoil = lerp(recoil, Vector2.ZERO, 0.2)
	# Raycast from camera to the world to adjust where bullets need to be pointed
	var ray_start = camera.global_transform.origin
	var aim_ray_end = camera.global_transform.origin - camera.global_transform.basis.z * 500
	var camera_raycast_result = space_state.intersect_ray(ray_start, aim_ray_end, [self])
	# Update where bullets are pointed
	aim_position = aim_ray_end
	if camera_raycast_result:
		aim_position = camera_raycast_result.position

func _unhandled_input(event):
	# Toggle 3rd person
	var just_pressed = event.is_pressed() and not event.is_echo()
	if Input.is_action_pressed("toggle_3p") and (event.is_pressed() and not event.is_echo()):
		toggle_third_person(!third_person)
		player.toggle_third_person(third_person)
	# Mouse zoom
	if event is InputEventMouseButton:
		if event.is_pressed():
			# Zoom in
			if event.button_index == BUTTON_WHEEL_UP and camera.fov > default_fov / 3:
				camera.fov -= default_fov / 9
			# Zoom out
			if event.button_index == BUTTON_WHEEL_DOWN and camera.fov < default_fov:
				camera.fov += default_fov / 9
	# Mouse look
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		# Horizontal look
		var rotation_y = deg2rad((-event.relative.x * ((adjusted_mouse_sensitivity.x / default_fov) * camera.fov)))
		# Vertical look
		var rotation_x = deg2rad((event.relative.y * ((adjusted_mouse_sensitivity.y / default_fov) * camera.fov)))
		# Apply rotations, clamp occurs in _process
		player.rotate_y(rotation_y)
		camera_pitch.rotate_x(rotation_x)

func viewport_size_changed():
	# Fix mouse sensitivity for varying resolutions
	var new_size = get_viewport().get_size()
	var new_x_sens = (new_size.x / intended_resolution.x) * mouse_sensitivity
	var new_y_sens = (new_size.y / intended_resolution.y) * mouse_sensitivity
	adjusted_mouse_sensitivity = Vector2(new_x_sens, new_y_sens)

func toggle_third_person(third_person_enabled: bool):
	if third_person_enabled:
		camera.transform.origin = third_person_offset
		third_person = true
	else:
		camera.transform.origin = Vector3.ZERO
		third_person = false

func add_shake(amount):
	cam_shake += amount
	if cam_shake > 0.2:
		cam_shake = 0.2
