extends KinematicBody

# Config
export(float) var move_speed = 8.0
export(float) var jump_speed = 12.0
export(float) var dodge_speed = 64.0
export(float) var gravity = -9.8
export(NodePath) var weapon_container

# Functional
var input_vector: Vector3 = Vector3.ZERO
var rotated_input_vector: Vector3 = Vector3.ZERO
var desired_velocity: Vector3 = Vector3.ZERO
var impact_velocity: Vector3 = Vector3.ZERO
var vertical_velocity: float = 0.0
var current_velocity: Vector3 = Vector3.ZERO
var is_grounded: bool = false
var current_weapon = null
var wep_cont_node = null

# Node assignments
onready var camera_controller = $CameraYaw
onready var right_hand_ik = $Armature/Skeleton/RightHandIK
onready var left_hand_ik = $Armature/Skeleton/LeftHandIK
onready var player_mesh = $Armature/Skeleton/CharacterMesh
onready var floor_check = $FloorCast
onready var anim_tree = $AnimationTree

# Utils
var input_amount = 1.0
var first_person_offset
var third_person_offset
onready var normal_material = preload("res://GR_assets/Player/Player_spatialmaterial.tres")
onready var invis_material = preload("res://GR_assets/Player/Invisible_spatialmaterial.tres")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	first_person_offset = self.transform.origin
	third_person_offset = camera_controller.transform.origin
	var wep_cont = get_node_or_null(weapon_container)
	if wep_cont:
		if wep_cont.get_child_count() > 0:
			print(current_weapon)
			current_weapon = wep_cont.get_child(0)
			print(current_weapon)
	# Set up IK
	right_hand_ik.start()
	left_hand_ik.start()

func _physics_process(delta):
	# Handle the basic movement key input here since many states use it
	input_vector = Vector3.ZERO
	if Input.is_action_pressed("move_forward"):
		input_vector.z += input_amount
	if Input.is_action_pressed("move_backward"):
		input_vector.z -= input_amount
	if Input.is_action_pressed("move_left"):
		input_vector.x += input_amount
	if Input.is_action_pressed("move_right"):
		input_vector.x -= input_amount
	input_vector = -input_vector.normalized()
	rotated_input_vector = input_vector.rotated(Vector3.UP, camera_controller.global_transform.basis.get_euler().y + PI)
	if impact_velocity.length() > 16.0:
		desired_velocity = impact_velocity
		anim_tree.set("parameters/dodge_blend/blend_amount", impact_velocity.length() / dodge_speed)
		if floor_check.is_colliding():
			Utils.instantiate(load("res://GR_assets/Effects/DustEffect.tscn"),  self.global_transform.origin, Vector3.UP)
	else:
		desired_velocity = lerp(desired_velocity, rotated_input_vector * move_speed, 1.0 - pow(0.01, delta))
		anim_tree.set("parameters/dodge_blend/blend_amount", 0.0)
	impact_velocity = lerp(impact_velocity, Vector3.ZERO, 1.0 - pow(0.1, delta))
	vertical_velocity_logic(delta)
	# Add everything together and move
	var final_move = desired_velocity + Vector3.UP * vertical_velocity - get_floor_normal() * 4.0
	current_velocity = move_and_slide(final_move, Vector3.UP, false, 4, 0.8, false)
	# Update ground status
	is_grounded = is_on_floor()
	# Do all the player stuff that isn't walking
	action_inputs()
	# Do animation stuff
	if is_grounded:
		anim_tree.set("parameters/run_blend/blend_position", convert_movement_to_anim(desired_velocity))
		anim_tree.set("parameters/jump_blend/blend_amount", 0.0)
	else:
		anim_tree.set("parameters/jump_blend/blend_amount", 1.0)
		anim_tree.set("parameters/jump_up_down/blend_position", vertical_velocity / jump_speed)
		
	if anim_tree.get("parameters/melee_1/active") == false:
		right_hand_ik.interpolation = 0.9
		left_hand_ik.interpolation = 0.9

func action_inputs():
	if Input.is_action_just_pressed("jump") and floor_check.is_colliding():
		vertical_velocity = jump_speed
	if Input.is_action_pressed("left_click"):
		if current_weapon != null:
			if current_weapon.fire(camera_controller.aim_position):
				camera_controller.recoil += current_weapon.recoil
	if Input.is_action_just_pressed("melee"):
		do_melee_attack()
	if Input.is_action_just_pressed("dodge") and impact_velocity.length() < 16.0:
		dodge(rotated_input_vector)

func dodge(direction: Vector3):
	var relative_dodge_dir = direction.rotated(Vector3(0,1.0,0), -self.global_transform.basis.get_euler().y)
	anim_tree.set("parameters/dodge_dir/blend_position", Vector2(-relative_dodge_dir.x, relative_dodge_dir.z))
	self.impact_velocity = direction * dodge_speed
	self.vertical_velocity = 4.0

func do_melee_attack():
	right_hand_ik.interpolation = 0.1
	left_hand_ik.interpolation = 0.1
	anim_tree.set("parameters/melee_1/active", true)

func vertical_velocity_logic(delta):
	# If our head hit something, end jump
	if is_on_ceiling():
		vertical_velocity = 0.0
	# On ground vs. in air calculations
	if is_grounded:
		if vertical_velocity <= 0.0:
			if input_vector.length() > 0.0:
				# If going down a slope
				if rad2deg(rotated_input_vector.angle_to(get_floor_normal())) - 90 < -0.01:
					vertical_velocity = -3.0
				# If going up a slope or flat surface
				else:
					vertical_velocity = 0.0
			else:
				vertical_velocity = 0
	else:
		# Downward accelerates faster for good game feel
		if vertical_velocity >= 0:
			vertical_velocity += gravity * delta
		else:
			vertical_velocity += gravity * 2.0 * delta

func convert_movement_to_anim(move_vector) -> Vector2:
	var retval = Vector2(0.0, 0.0)
	var measure_vector = (move_vector / move_speed)
	measure_vector = (measure_vector as Vector3).rotated(Vector3(0,1.0,0), -self.global_transform.basis.get_euler().y)
	retval.y = measure_vector.z
	retval.x = -measure_vector.x
	return retval

func toggle_third_person(third_person_enabled: bool):
	if !third_person_enabled:
		player_mesh.set_surface_material(0, invis_material)
	else:
		player_mesh.set_surface_material(0, normal_material)
		
