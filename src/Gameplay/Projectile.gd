extends Spatial

# Config
export var drag: float = 0.0
export var gravity: float = 0.0
export var leave_projectile: bool = false
# Misc
export(Array, PackedScene) var impact_effects

# Functional
var dmg
var _timer
var velocity: Vector3 = Vector3.ZERO
var velocity_and_gravity: Vector3 = Vector3.ZERO
var added_gravity: float = 0.0
var bullet_mesh: Spatial = null
var fx_cache
var ignore_array: Array
var spindir: Vector3
var spinrot: float = 360.0

func init(newdmg, newvelocity, nohitarray):
	ignore_array = nohitarray
	dmg = newdmg
	velocity = self.global_transform.basis.z * newvelocity
	velocity_and_gravity = Vector3(velocity.x, velocity.y + added_gravity, velocity.z)
	$ImpactRay.cast_to = Vector3.BACK * velocity.length() * 0.016
	$ImpactRay.enabled = true
	bullet_mesh = $MeshInstance
	_timer = Timer.new()
	add_child(_timer)
	_timer.connect("timeout", self, "_on_Timer_timeout")
	_timer.set_wait_time(3.0)
	_timer.start()
	# Add a little variation to the drag
	drag += rand_range(-drag / 5.0, drag / 5.0)


func _process(delta):
	velocity_and_gravity = Vector3(velocity.x, velocity.y + added_gravity, velocity.z)
	$ImpactRay.cast_to = Vector3.BACK * velocity_and_gravity.length() * delta
	$ImpactRay.force_raycast_update()
	if $ImpactRay.is_colliding() and ignore_array.find($ImpactRay.get_collider()) == -1:
		do_impact($ImpactRay.get_collider(), $ImpactRay.get_collision_point(), $ImpactRay.get_collision_normal())
	if drag != 0.0:
		velocity *= 1 - ((drag * delta) / velocity.length())
	if gravity != 0.0:
		Utils.fixed_look_at(self, self.global_transform.origin - (velocity_and_gravity))
		added_gravity += gravity * delta
	self.global_translate(velocity_and_gravity * delta)

func do_impact(collider, point, normal):
	# Make the mesh stay stuck in the wall
	if leave_projectile:
		var cachepos = bullet_mesh.global_transform
		self.remove_child(bullet_mesh)
		collider.add_child(bullet_mesh)
		bullet_mesh.global_transform = cachepos
		bullet_mesh.global_transform.origin = point
	if collider is RigidBody:
		collider.apply_impulse(point - collider.global_transform.origin, velocity_and_gravity * 0.01)
	if collider.has_method("take_damage"):
		collider.take_damage(point, normal, dmg)
	if impact_effects.size() > 0:
		for n in range(impact_effects.size()):
			if impact_effects[n] != null:
				Utils.instantiate(impact_effects[n], point, normal, 1.0, collider)
	queue_free()

func _on_Timer_timeout():
	queue_free()
