extends EnemyClass

export(PackedScene) var projectile
export(float) var spread
export(float) var muzzle_velocity
export(float) var damage

onready var animationPlayer: AnimationPlayer = $AnimationPlayer
onready var flying_nav: Flying_Nav = get_tree().get_nodes_in_group("Flying_Nav")[0]
var nav_point: Vector3

enum State {WALK, ATTACK}
var current_state: int
var speed: int = 20

func _ready():
	
	enter_state(State.WALK)
	nav_point = flying_nav.generate_nav_point()
	
func enter_state(new_state):
	current_state = new_state
	
	match current_state:
		
		State.WALK:
			#If travel takes more then 5 seconds then attack
			$TravelTimer.start(3) #attack after this
			play_animation("Flying")
		
		State.ATTACK:
			play_animation("Attack")
			
func _physics_process(delta):
	
	dist2player = global_transform.origin.distance_squared_to(player_position)
	
	match current_state:
			
		State.WALK:
			Utils.fixed_look_at(self, nav_point)
			move_and_slide(global_transform.origin.direction_to(nav_point) * speed * speed_modifier, Vector3.UP)
			
			if global_transform.origin.distance_squared_to(nav_point) < 5:
				enter_state(State.ATTACK)
				
				
		State.ATTACK:
			look_at(player_position, Vector3.UP)


func play_animation(anim_name: String):
	match anim_name:
			
		"Flying":
			animationPlayer.play("Flying")
			animationPlayer.set_speed_scale(2)
		
		"Attack":
			animationPlayer.play("Attack")
			animationPlayer.set_speed_scale(1)



func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"Attack":
			nav_point = flying_nav.generate_nav_point()
			enter_state(State.WALK)

func shoot_attack():
	var bullet = projectile.instance()
	Globals.scene_root.add_child(bullet)
	bullet.global_transform.origin = self.global_transform.origin
	# Direction is usually normalized but, just to be sure
	var new_dir = self.global_transform.origin.direction_to(player_position + Vector3.UP)
	# Apply random spread on local axes
	var original_dir = new_dir
	new_dir = new_dir.rotated(new_dir.cross(Vector3.UP).normalized(), rand_range(-deg2rad(spread), deg2rad(spread)))
	new_dir = new_dir.rotated(original_dir, rand_range(0, 2 * PI))
	# Point the bullet towards the final direction
	Utils.fixed_look_at(bullet, bullet.transform.origin - new_dir)
	bullet.init(damage, muzzle_velocity, [self])

func die():
	Utils.instantiate(bigsplat, self.global_transform.origin, Vector3.FORWARD, 0.5)
	.die()
	call_deferred("free")

func _on_TravelTimer_timeout():
	enter_state(State.ATTACK)
