extends KinematicBody
class_name EnemyClass

export var health: int

var path = []
var path_node = 0

var player: KinematicBody
var player_position: Vector3
var dist2player: float

var nav: Navigation

func _ready():
	# Access navigation node
	nav = get_tree().get_nodes_in_group("Navigation")[0]
	player = get_tree().get_nodes_in_group("Player")[0]
	
func _physics_process(delta):
	player_position = player.global_transform.origin
	
	# If there are still points to go
	if path_node < path.size():
		
		# get direction to next point
		var dir:Vector3 = (path[path_node] - global_transform.origin)
		
		# if you are very close to the point then select next point
		if dir.length_squared() < 5:
			path_node += 1
		
		# move to point
		else:
			process_movement(dir)
			
			
func process_movement(direction):
	# put enemy movement script here
	pass

func get_new_path(target_pos):
	path = nav.get_simple_path(global_transform.origin, target_pos)
	path_node = 0

func take_damage(point, normal, damage):
	Utils.instantiate(load("res://GR_assets/Effects/bloodhit/BloodHit.tscn"), self.global_transform.origin, self.global_transform.basis.z, 12.0)
	health -= damage
	if health <= 0:
		die()

func die():
	var blood_glob = load("res://GR_assets/Effects/bloodglob/BloodGlob.tscn")
	var blood_hit = load("res://GR_assets/Effects/bloodhit/BloodHit.tscn")
	var blood_pickup = load("res://GR_assets/Gameplay/BloodPickup.tscn")
	Utils.instantiate(blood_pickup, self.global_transform.origin + Vector3.UP, Vector3.UP)
	Utils.instantiate(blood_pickup, self.global_transform.origin + Vector3.UP, Vector3.UP)
	Utils.instantiate(blood_pickup, self.global_transform.origin + Vector3.UP, Vector3.UP)
	Utils.instantiate(blood_glob, self.global_transform.origin + Vector3.UP, Vector3.UP, 3.0)
	Utils.instantiate(blood_glob, self.global_transform.origin + Vector3.UP, Vector3.UP, 3.0)
	Utils.instantiate(blood_hit, self.global_transform.origin, self.global_transform.basis.z, 8.0)
	pass
