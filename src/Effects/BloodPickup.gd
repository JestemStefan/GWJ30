extends RigidBody

func _ready():
	var direction = Vector3.UP
	var spread = 45.0
	direction = direction.rotated(direction.cross(Vector3.FORWARD).normalized(), rand_range(-deg2rad(spread), deg2rad(spread)))
	direction = direction.rotated(Vector3.UP, rand_range(0, 2 * PI))
	self.apply_central_impulse(direction * 10.0)
	
