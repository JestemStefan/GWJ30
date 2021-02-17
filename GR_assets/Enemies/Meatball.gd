extends RigidBody
class_name Meatball


var direction: Vector3 = Vector3.ZERO
var velocity: int = 30

func _ready():
	set_linear_velocity(direction * velocity)
