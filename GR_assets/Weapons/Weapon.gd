extends RigidBody

export var damage = 1.0
export var fire_rate = 0.15
export var burst: int = 1
export var burst_rate: float = 0.0
export var spread: float =  2.0
export var ammo: int = 128
export var recoil: Vector2 = Vector2.ZERO
export var muzzle_velocity: float
export var projectiles_per_shot: int
export var audio_one_shot: bool
export (PackedScene) var projectile


var current_ammo = 128
var can_shoot: bool = true

var muzzle: Spatial
var muzzle_flash: Particles
var rof_timer: Timer
var sfx_timer: Timer
var sfx: AudioStreamPlayer3D
var parent_arm = null

func _ready():
	muzzle = $WeaponMuzzle as Spatial
	muzzle_flash = $WeaponMuzzle/Particles as Particles
	rof_timer = $ShootTimer as Timer
	sfx_timer = $SfxTimer as Timer
	sfx = $ShootSound
	if not rof_timer.is_connected("timeout", self, "shoot_timer_timeout"):
		var _a = rof_timer.connect("timeout", self, "shoot_timer_timeout")
	if not sfx_timer.is_connected("timeout", self, "sfx_timer_timeout"):
		var _b = sfx_timer.connect("timeout", self, "sfx_timer_timeout")

# Try to fire the weapon. Returns true if it fired
func fire(point_to_shoot: Vector3) -> bool:
	var direction = get_vector_to_location(muzzle, point_to_shoot)
	if can_shoot and current_ammo > 0:
		can_shoot = false
		rof_timer.start(fire_rate)
		if not audio_one_shot:
			if not sfx.playing:
				sfx.play()
		if burst > 1:
			for n in range(0, burst):
				per_shot(direction)
				yield(get_tree().create_timer(burst_rate), "timeout")
		else:
			per_shot(direction)
		return true
	else:
		return false

func per_shot(direction):
	if audio_one_shot:
		sfx.play(0.0)
	muzzle_flash.restart()
	muzzle_flash.emitting = true
	for _n in range(projectiles_per_shot):
		var bullet = projectile.instance()
		Globals.scene_root.add_child(bullet)
		bullet.global_transform.origin = muzzle.global_transform.origin
		# Direction is usually normalized but, just to be sure
		var new_dir = direction.normalized()
		# Apply random spread on local axes
		var original_dir = new_dir
		new_dir = new_dir.rotated(new_dir.cross(Vector3.UP).normalized(), rand_range(-deg2rad(spread), deg2rad(spread)))
		new_dir = new_dir.rotated(original_dir, rand_range(0, 2 * PI))
		# Point the bullet towards the final direction
		bullet.look_at(bullet.transform.origin - new_dir, Vector3.UP)
		bullet.init(damage, muzzle_velocity, [self])

func shoot_timer_timeout():
	can_shoot = true
	sfx_timer.start(0.05)

# If .05 seconds passed since shooting was allowed, and we still haven't shot again, assume player stopped shooting.
func sfx_timer_timeout():
	if sfx.playing and can_shoot:
		sfx.stop()

func get_vector_to_location(base, location) -> Vector3:
	var dist_to_loc = base.global_transform.origin.distance_to(location)
	var vec_to_loc = location - base.global_transform.origin
	var gun_forward = base.global_transform.basis.z
	if dist_to_loc < 10.0:
		vec_to_loc = lerp(vec_to_loc, gun_forward, 1 - (dist_to_loc / 10.0))
	return vec_to_loc
