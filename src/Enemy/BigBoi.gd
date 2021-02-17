extends EnemyClass

onready var animationPlayer: AnimationPlayer = $AnimationPlayer
onready var projectile_origin: Spatial = $ProjectileSpawn
onready var meatball = preload("res://GR_assets/Enemies/Meatball.tscn")

enum State {IDLE, WALK, ATTACK, SHOOT, DIE}
var current_state: int
var speed: int = 10

var projectile_speed: int = 30

func _ready():
	._ready()
	enter_state(State.WALK)

func enter_state(new_state):
	current_state = new_state
	
	match current_state:
		State.IDLE:
			play_animation("Idle")
			
		State.WALK:
			play_animation("Walk")
		
			
		State.ATTACK:
			play_animation("Attack")
			
			# TODO: Deal damage
		State.SHOOT:
			var angle = calculate_shooting_angle(sqrt(dist2player * 0.6))
			var projectile: Meatball = meatball.instance()
			var shoot_dir: Vector3 = -global_transform.basis.z
			projectile.direction = shoot_dir.rotated(Vector3.RIGHT, angle)
			self.get_parent().add_child(projectile)
			projectile.global_transform.origin = projectile_origin.global_transform.origin
			play_animation("Shoot")

		State.DIE:
			pass

func process_movement(direction):
	
	dist2player = global_transform.origin.distance_squared_to(player_position)
	
	
	match current_state:
		State.IDLE:
			pass
			
		State.WALK:
			Utils.fixed_look_at(self, path[path_node])
			move_and_slide(direction.normalized() * speed * speed_modifier, Vector3.UP)
			
			if dist2player < 20:
				enter_state(State.ATTACK)
			
			elif dist2player > 300 and dist2player < 500:
				enter_state(State.SHOOT)
			
		State.ATTACK:
			look_at(player_position, Vector3.UP)
		
		State.SHOOT:
			look_at(player_position, Vector3.UP)
			
			if dist2player < 300 or dist2player > 500:
				enter_state(State.WALK)
		
		State.DIE:
			pass
	
func play_animation(anim_name: String):
	match anim_name:
		"Idle":
			animationPlayer.play("Idle")
			animationPlayer.set_speed_scale(1)
			
		"Walk":
			animationPlayer.play("Walk")
			animationPlayer.set_speed_scale(2)
		
		"Attack":
			var attack: String = ["Attack", "Attack2"][randi()%2]
			animationPlayer.play(attack)
			animationPlayer.set_speed_scale(1.5)
			
		"Shoot":
			animationPlayer.play("Shoot")
			animationPlayer.set_speed_scale(1)

func die():
	.die()
	call_deferred("free")


func calculate_shooting_angle(distance_to_target):
	return 0.5 * asin((9.8 * distance_to_target)/pow(projectile_speed, 2))

func _on_PathTimer_timeout():
	get_new_path(player_position) #put target in parameter

func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"Attack", "Attack2":
			if dist2player > 20:
				enter_state(State.WALK)
			else:
				enter_state(State.ATTACK)
		
		"Shoot":
			enter_state(State.SHOOT)

func melee_do_hit():
	.melee_do_hit()
