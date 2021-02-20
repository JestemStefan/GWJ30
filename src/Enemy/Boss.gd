extends StaticBody
class_name Boss

# State Machine
enum State{IDLE, SPAWNING, DAMAGED, DIE}
var current_state: int

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
	enter_state(State.IDLE)

func enter_state(new_state):
	current_state = new_state
	
	match current_state:
		
		State.IDLE:
			play_animation("Idle")
			spawn_timer.start(3)
		
		State.SPAWNING:
			play_animation("Spawn")
			# spawning method call will take place in animation
		
		State.DAMAGED:
			play_animation("Damage")
		
		State.DIE:
			pass


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
			pass


func _on_AnimationPlayer_animation_finished(anim_name):
	
	match anim_name:
		
		"Idle":
			pass
			
		"Spawn":
			enter_state(State.IDLE)
			
		"Damage":
			enter_state(State.IDLE)
		
		"Dead":
			pass


func heart_destoyed():
	print("heart destroyed")
	enter_state(State.DAMAGED)


func spawn_eggs():
	pass


func _on_SpawnTimer_timeout():
	enter_state(State.SPAWNING)
