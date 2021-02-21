extends StaticBody
class_name Boss

# State Machine
enum State{IDLE, SPAWNING, DAMAGED, DIE}
var current_state: int

var current_wave: int

onready var player = get_tree().get_nodes_in_group("Player")[0]
onready var HUD = get_tree().get_nodes_in_group("HUD")[0]
onready var anim_player: AnimationPlayer = $AnimationPlayer

# Spawning
onready var spawn_timer: Timer = $SpawnTimer
onready var spawn_egg = preload("res://GR_assets/Gameplay/SpawnEgg.tscn")

# Hearts
onready var heart1: StaticBody = $Armature/Skeleton/BoneAttachment/Heart
onready var heart2: StaticBody = $Armature/Skeleton/BoneAttachment/Heart2
onready var heart3: StaticBody = $Armature/Skeleton/BoneAttachment2/Heart
onready var heart4: StaticBody = $Armature/Skeleton/BoneAttachment2/Heart2

onready var heartplate_1: StaticBody = $Armature/Skeleton/BoneAttachment/Heartplate1
onready var heartplate_2: StaticBody = $Armature/Skeleton/BoneAttachment/Heartplate2
onready var heartplate_3: StaticBody = $Armature/Skeleton/BoneAttachment2/Heartplate3
onready var heartplate_4: StaticBody = $Armature/Skeleton/BoneAttachment2/Heartplate4


func _ready():
	spawn_timer.start(10)
	current_wave = 1
	
	enter_state(State.IDLE)

func enter_state(new_state):
	current_state = new_state
	
	match current_state:
		
		State.IDLE:
			play_animation("Idle")
			
		
		State.SPAWNING:
			play_animation("Spawn")
			# spawning method call will take place in animation
		
		State.DAMAGED:
			play_animation("Damage")
		
		State.DIE:
			play_animation("Dead")
			$SpawnTimer.stop()
			$LeechTimer.stop()
			var all_enemies = get_tree().get_nodes_in_group("Enemy")
			for enemy in all_enemies:
				if enemy is Meatball or enemy is Egg:
					enemy.call_deferred("free")
				else:
					enemy.die()


func _process(delta):

	match current_state:
		
		State.IDLE:
			pass
		
		State.SPAWNING:
			pass
		
		State.DAMAGED:
			pass
		
		State.DIE:
			pass


func play_animation(anim_name: String):
	
	match anim_name:
		
		"Idle":
			anim_player.play("Idle")
			
		"Spawn":
			anim_player.play("Spawn")
			
		"Damage":
			anim_player.play("Damage")
		
		"Dead":
			anim_player.play("Dead")


func _on_AnimationPlayer_animation_finished(anim_name):
	
	match anim_name:
		
		"Idle": 
			pass
			
		"Spawn":
			var heartplate_to_delete
			match current_wave:
				1:
					heartplate_to_delete = heartplate_1
					heart1.enabled = true
				2:
					heartplate_to_delete = heartplate_2
					heart2.enabled = true
				3:
					heartplate_to_delete = heartplate_3
					heart3.enabled = true
				4:
					heartplate_to_delete = heartplate_4
					heart4.enabled = true
					
			heartplate_to_delete.call_deferred("free")
			enter_state(State.IDLE)
			
		"Damage":
			
			current_wave += 1
			print(current_wave)
			if current_wave > 4:
				enter_state(State.DIE)
				player.isInvincibile = true
				
				#Trigger endgame
				
			else:
				spawn_timer.start(5)
				enter_state(State.IDLE)
						
			
		"Dead":
			HUD.game_won()


func heart_destoyed():
	#print("heart destroyed")
	enter_state(State.DAMAGED)
	


func spawn_eggs():
	var egg:Egg = spawn_egg.instance()
	var shoot_dir: Vector3 = Vector3(0,1,-1)
	egg.direction = shoot_dir.rotated(Vector3.UP, rand_range(-PI, PI))
	#projectile.direction = self.global_transform.origin.direction_to(player_position + Vector3.UP)
	self.get_parent().add_child(egg)
	egg.wave = current_wave
	egg.global_transform.origin = $Spawn_Position.global_transform.origin


func _on_SpawnTimer_timeout():
	enter_state(State.SPAWNING)


func _on_LeechTimer_timeout():
	spawn_eggs()
