extends Node

func instantiate(obj: PackedScene, point: Vector3, direction: Vector3, scale: float = 1.0, parent = null):
	var new_obj = obj.instance()
	if parent != null:
		parent.add_child(new_obj)
		var fix_scale = parent.global_transform.basis.get_scale()
		new_obj.set_scale(Vector3(1/fix_scale.x, 1/fix_scale.y, 1/fix_scale.z)) #3D
	else:
		Globals.scene_root.add_child(new_obj)
	# Bump the object a tiny bit off the direction it was created at
	new_obj.global_transform = Transform(Basis.IDENTITY, point + direction/5.0)
	Utils.fixed_look_at(new_obj, point - direction)
	new_obj.global_scale(Vector3.ONE * scale)

# Constrain x between lo and hi, wrapping around
func constrain(x, lo, hi) -> float:
	var t = fmod(x - lo, hi - lo)
	if t < 0:
		return t + hi
	else:
		return t + lo

func constant_speed_yaw(object: Spatial, point_to_face: Vector3, rot_speed: float, delta: float):
	var direction = point_to_face.direction_to(object.global_transform.origin)
	var front = object.global_transform.basis.z
	var ang = Vector2(front.x, front.z).angle_to(Vector2(direction.x, direction.z))
	var s = sign(ang)
	if abs(rad2deg(ang)) <= 179.99:
		object.rotate_y(clamp(180 - abs(rad2deg(ang)), 0.01, rot_speed) * delta * s)

func fixed_look_at(obj: Spatial, lookat: Vector3):
	var dir_between = obj.global_transform.origin.direction_to(lookat)
	if dir_between.is_equal_approx(Vector3.UP):
		obj.rotation_degrees.x = -90
	elif dir_between.is_equal_approx(Vector3.DOWN):
		obj.rotation_degrees.x = 90
	elif not obj.global_transform.origin.is_equal_approx(lookat):
		obj.look_at(lookat, Vector3.UP)

func fixed_looking_at(trans: Transform, lookat: Vector3) -> Transform:
	var new_trans = Transform(trans)
	var dir_between = new_trans.origin.direction_to(lookat)
	if not dir_between.is_equal_approx(Vector3.UP):
		if not dir_between.is_equal_approx(Vector3.DOWN):
			if not new_trans.origin.is_equal_approx(lookat):
				new_trans = new_trans.looking_at(lookat, Vector3.UP)
	return new_trans

func fixed_look_at_y(obj: Spatial, lookat: Vector3):
	# 0 out the y coord to only look on one axis
	var test_trans = Transform(obj.global_transform.basis, Vector3(obj.global_transform.origin.x, 0.0, obj.global_transform.origin.z))
	var test_lookat = Vector3(lookat.x, 0.0, lookat.z)
	var dir_between = Utils.get_flat_direction(obj.global_transform.origin, test_lookat)
	if not dir_between.is_equal_approx(Vector3.UP):
		if not dir_between.is_equal_approx(Vector3.DOWN):
			if not test_trans.origin.is_equal_approx(test_lookat):
				test_trans = test_trans.looking_at(test_lookat, Vector3.UP)
	obj.global_transform.basis = test_trans.basis

func fixed_looking_at_y(trans: Transform, lookat: Vector3) -> Transform:
	# 0 out the y coord to only look on one axis
	var test_trans = Transform(trans.basis, Vector3(trans.origin.x, 0.0, trans.origin.z))
	var test_lookat = Vector3(lookat.x, 0.0, lookat.z)
	var dir_between = test_trans.origin.direction_to(test_lookat)
	if not dir_between.is_equal_approx(Vector3.UP):
		if not dir_between.is_equal_approx(Vector3.DOWN):
			if not test_trans.origin.is_equal_approx(test_lookat):
				test_trans = test_trans.looking_at(test_lookat, Vector3.UP)
	return test_trans

func get_flat_direction(start: Vector3, dest: Vector3) -> Vector3:
	var self_no_y = Vector3(start.x, 0.0, start.z)
	var point_no_y = Vector3(dest.x, 0.0, dest.z)
	return self_no_y.direction_to(point_no_y)

func get_flat_distance(start: Vector3, dest: Vector3) -> Vector3:
	var self_no_y = Vector3(start.x, 0.0, start.z)
	var point_no_y = Vector3(dest.x, 0.0, dest.z)
	return self_no_y.distance_to(point_no_y)

func do_hitstop(time: float):
	Engine.time_scale = 0.1
	yield(get_tree().create_timer(time), "timeout")
	Engine.time_scale = 1.0

func slow_hitstop(time: float):
	Engine.time_scale = 0.5
	yield(get_tree().create_timer(time), "timeout")
	Engine.time_scale = 1.0
