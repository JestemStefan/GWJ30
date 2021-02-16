extends Spatial

export(PackedScene) var splatter

var velocity : Vector3 = Vector3.ZERO
var gravity = -24
var speed = 0.0

func _ready():
	speed = rand_range(9.0, 18.0)
	velocity = Vector3(rand_range(-1.0, 1.0) * speed, rand_range(0.0, 1.0) * speed, rand_range(-1.0, 1.0) * speed)

func _physics_process(delta):
	self.global_transform.origin += velocity * delta
	velocity.y += gravity * delta
	self.look_at(self.get_global_transform().origin - velocity, Vector3.UP)
	if $RayCast.is_colliding():
		var decal = splatter.instance()
		Globals.scene_root.add_child(decal)
		var hitpos = $RayCast.get_collision_point()
		var hitnorm = $RayCast.get_collision_normal()
		decal.global_transform.origin = hitpos
		Utils.fixed_look_at(decal, hitpos + hitnorm)
		self.queue_free()
