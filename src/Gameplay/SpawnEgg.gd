extends RigidBody
class_name Egg

var spawning: bool = false
var enemies_spawn: int = 0
var max_enemies_spawned: int = 1

onready var leech = preload("res://GR_assets/Enemies/Leech.tscn")
onready var bigboi = preload("res://GR_assets/Enemies/BigBoi.tscn")
onready var warrior = preload("res://GR_assets/Enemies/Warrior.tscn")
onready var watcher = preload("res://GR_assets/Enemies/Watcher.tscn")

var direction: Vector3 = Vector3.ZERO
var velocity: int = 10

func _ready():
	pass
	#yield(get_tree().create_timer(0.1), "timeout")
	#_on_Timer_timeout()
	
	randomize()
	set_linear_velocity(direction * velocity)
	set_angular_velocity(Vector3(rand_range(-10, 10), rand_range(-10, 10), rand_range(-10, 10)))

func _on_Timer_timeout():
	if enemies_spawn < max_enemies_spawned:
		var chance = randi() % 6
		if chance <= 1:
			Utils.instantiate(leech, self.global_transform.origin, Vector3.FORWARD)
			pass
		elif chance <= 2:
			Utils.instantiate(bigboi, self.global_transform.origin, Vector3.FORWARD)
			pass
		elif chance <= 4:
			Utils.instantiate(warrior, self.global_transform.origin, Vector3.FORWARD)
			pass
		else:
			Utils.instantiate(watcher, self.global_transform.origin, Vector3.FORWARD)
			pass
		enemies_spawn += 1
	
	else:
		call_deferred("free")
		
	# What does it do? [JestemStefan]
	if $Timer.wait_time > 3.0:
		$Timer.wait_time -= 0.5


func _on_SpawnEgg_body_entered(body):
	if !spawning:
		if body.is_in_group("Floor"):
			#var spawn = leech.instance()
			#get_parent().add_child(spawn)
			#spawn.set_global_transform(global_transform)
			spawning = true
			$Timer.start(1)
		
		#call_deferred("free")
