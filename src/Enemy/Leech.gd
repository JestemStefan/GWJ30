extends EnemyClass

onready var animationPlayer: AnimationPlayer = $AnimationPlayer

enum State {IDLE, WALK, ATTACK, DIE}
var current_state: int
var speed: int = 10

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
			
		State.DIE:
			pass

func process_movement(direction, delta):
	
	dist2player = global_transform.origin.distance_squared_to(player_position)
	
	match current_state:
		State.IDLE:
			pass
			
		State.WALK:
			Utils.fixed_look_at(self, path[path_node])
			move_and_slide(direction.normalized() * speed * speed_modifier, Vector3.UP)
			
			if dist2player < 10:
				enter_state(State.ATTACK)
			
		State.ATTACK:
			look_at(path[path_node], Vector3.UP)
			
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
			animationPlayer.play("Attack")
			animationPlayer.set_speed_scale(1)
		

func die():
	.die()
	call_deferred("free")

func _on_PathTimer_timeout():
	get_new_path(player_position) #put target in parameter


func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"Attack":
			if dist2player > 20:
				enter_state(State.WALK)
			else:
				enter_state(State.ATTACK)

func melee_do_hit():
	.melee_do_hit()
