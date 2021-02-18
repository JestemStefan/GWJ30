extends RigidBody
class_name Meatball

onready var leech = preload("res://GR_assets/Enemies/Leech.tscn")

var direction: Vector3
var velocity: int = 30

func _ready():
	randomize()
	set_linear_velocity(direction * velocity)
	set_angular_velocity(Vector3(rand_range(-10, 10), rand_range(-10, 10), rand_range(-10, 10)))


func _on_Meatball_body_entered(body):
	if body.is_in_group("Floor"):
		var spawn = leech.instance()
		get_parent().add_child(spawn)
		spawn.global_transform.origin = global_transform.origin
		
		call_deferred("free")
