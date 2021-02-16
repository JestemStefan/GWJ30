extends Entity
class_name EnemyClass

var path = []
var path_node = 0

var player: KinematicBody
var player_position: Vector3
var dist2player: float

var nav: Navigation

func _ready():
	._ready()
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
