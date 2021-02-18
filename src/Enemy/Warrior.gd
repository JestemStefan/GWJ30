extends EnemyClass

# Config

export(float) var gravity = -9.8
export(NodePath) var weapon_container

# Functional
var move_speed = 8.0
var jump_speed = 12.0
var dodge_speed = 64.0
var input_vector: Vector3 = Vector3.ZERO
var rotated_input_vector: Vector3 = Vector3.ZERO
var desired_velocity: Vector3 = Vector3.ZERO
var impact_velocity: Vector3 = Vector3.ZERO
var vertical_velocity: float = 0.0
var current_velocity: Vector3 = Vector3.ZERO
var is_grounded: bool = false
var is_sliding: bool = false
var current_weapon = null
var wep_cont_node = null

# Gameplay
var aim_position = Vector3.ZERO

# Node assignments
onready var right_hand_ik = $Armature/Skeleton/RightHandIK
onready var player_mesh = $Armature/Skeleton/CharacterMesh
onready var floor_check = $FloorCast
onready var anim_tree = $AnimationTree

# Utils
var input_amount = 1.0
var new_ik_interp: float

func _ready():
	var wep_cont = get_node_or_null(weapon_container)
	if wep_cont:
		if wep_cont.get_child_count() > 0:
			print(current_weapon)
			current_weapon = wep_cont.get_child(0)
			print(current_weapon)
	anim_tree.active = true
	# Set up IK
	right_hand_ik.start()

func _physics_process(delta):
	rotated_input_vector = get_move_vector()
	# Handle sliding
	if impact_velocity.length() > 16.0:
		is_sliding = true
		desired_velocity = impact_velocity
		anim_tree.set("parameters/dodge_blend/blend_amount", impact_velocity.length() / dodge_speed)
		if floor_check.is_colliding():
			Utils.instantiate(load("res://GR_assets/Effects/DustEffect.tscn"),  self.global_transform.origin, Vector3.UP)
	else:
		is_sliding = false
		desired_velocity = lerp(desired_velocity, rotated_input_vector * move_speed, 1.0 - pow(0.01, delta))
		anim_tree.set("parameters/dodge_blend/blend_amount", 0.0)
	# Slow sliding speed down
	impact_velocity = lerp(impact_velocity, Vector3.ZERO, 1.0 - pow(0.2, delta))
	# Add up/down logic
	vertical_velocity_logic(delta)
	# Add everything together and move
	var final_move = desired_velocity + Vector3.UP * vertical_velocity - get_floor_normal() * 4.0
	current_velocity = move_and_slide(final_move, Vector3.UP, false, 4, 0.8, false)
	# Update ground status
	is_grounded = is_on_floor()
	# Do all the player stuff that isn't walking
	action_ai()
	# Do animation stuff
	if is_grounded:
		anim_tree.set("parameters/run_blend/blend_position", convert_movement_to_anim(desired_velocity))
		anim_tree.set("parameters/run_speed/scale", current_velocity.length() / move_speed)
		anim_tree.set("parameters/jump_blend/blend_amount", 0.0)
	else:
		var current_jump_blend = anim_tree.get("parameters/jump_blend/blend_amount")
		anim_tree.set("parameters/jump_blend/blend_amount", lerp(current_jump_blend, 1.0, 5.0 * delta))
		anim_tree.set("parameters/jump_up_down/blend_position", vertical_velocity / jump_speed)
	if anim_tree.get("parameters/melee/active") == false:
		new_ik_interp = 0.9 - anim_tree.get("parameters/dodge_blend/blend_amount")
	# Finalize the IK interp so its always smooth
	right_hand_ik.interpolation = lerp(right_hand_ik.interpolation, new_ik_interp, 3.0 * delta)

func get_move_vector() -> Vector3:
	return Utils.get_flat_direction(self.global_transform.origin, player_position)
	#return input_vector.rotated(Vector3.UP, camera_controller.global_transform.basis.get_euler().y + PI)

func action_ai():
	aim_position = player_position
	#if Input.is_action_just_pressed("jump") and floor_check.is_colliding():
	#	vertical_velocity = jump_speed
	#if Input.is_action_pressed("left_click"):
	#	if current_weapon != null:
	#		current_weapon.fire(aim_position)
	#if Input.is_action_pressed("melee") and anim_tree.get("parameters/melee/active") == false and not is_sliding:
	#	do_melee_attack()
	#if Input.is_action_just_pressed("dodge") and not is_sliding:
	#	dodge(rotated_input_vector)

func dodge(direction: Vector3):
	var relative_dodge_dir = direction.rotated(Vector3(0,1.0,0), -self.global_transform.basis.get_euler().y)
	anim_tree.set("parameters/dodge_dir/blend_position", Vector2(-relative_dodge_dir.x, relative_dodge_dir.z))
	self.impact_velocity = direction * dodge_speed
	self.vertical_velocity = 4.0

func do_melee_attack():
	right_hand_ik.interpolation = 0.02
	#right_hand_ik.stop()
	#left_hand_ik.stop()
	anim_tree.set("parameters/melee/active", true)
	#self.impact_velocity = self.global_transform.basis.z * 12.0
	if is_equal_approx(anim_tree.get("parameters/melee_choice/blend_amount"), 0.0):
		anim_tree.set("parameters/melee_choice/blend_amount", 1.0)
	else:
		anim_tree.set("parameters/melee_choice/blend_amount", 0.0)

# OVERRIDE
func melee_do_hit():
	var query = PhysicsShapeQueryParameters.new()
	#query.set_collision_mask()
	query.set_collide_with_areas(false)
	query.exclude = [self]
	query.set_shape(melee_shape.get_shape())
	query.set_transform(melee_shape.get_global_transform())
	var hits = space_state.intersect_shape(query)
	if not hits.empty():
		# One-off hit things
		if not is_grounded:
			#vertical_velocity = 10.0
			pass
	for hit in hits:
		if is_instance_valid(hit["collider"]):
			if hit["collider"].has_method("take_damage"):
				hit["collider"].take_damage(self.global_transform.origin, self.global_transform.basis.z, 20.0)

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

# OVERRIDE
func take_damage(point, normal, damage):
	do_damage_flash(true, 0)
	do_damage_flash(true, 1)
	do_damage_flash(false, 0)
	do_damage_flash(false, 1)
	self.impact_velocity += Utils.get_flat_direction(point, self.global_transform.origin) * 15.0

func die():
	.die()
	queue_free()
