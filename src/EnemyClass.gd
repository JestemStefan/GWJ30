extends Entity
class_name EnemyClass

# Config
export var melee_damage: float = 5.0
export var melee_knockback: float = 0.0
export var speed_modifier: float = 1
export var kill_hr_reward: float = 10.0
export var kill_blood_reward: int = 2


var path = []
var path_node = 0

var player: KinematicBody
var player_position: Vector3
var dist2player: float

var nav: Navigation

# Melee
onready var melee_shape = $MeleeShape
onready var space_state = get_world().get_direct_space_state()

# Other
var blood_pickup = preload("res://GR_assets/Gameplay/BloodPickup.tscn")

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
			process_movement(dir, delta)
			
			
func process_movement(direction, delta):
	# put enemy movement script here
	pass

func get_new_path(target_pos):
	path = nav.get_simple_path(global_transform.origin, target_pos)
	path_node = 0

func melee_do_hit():
	var query = PhysicsShapeQueryParameters.new()
	#query.set_collision_mask()
	query.set_collide_with_areas(false)
	query.exclude = [self]
	query.set_shape(melee_shape.get_shape())
	query.set_transform(melee_shape.get_global_transform())
	var hits = space_state.intersect_shape(query)
	for hit in hits:
		var target = hit["collider"]
		if is_instance_valid(target) and target.is_in_group("Player"):
				var midpoint = self.global_transform.origin - (self.global_transform.origin - target.global_transform.origin)/2
				target.impact_velocity = Utils.get_flat_direction(self.global_transform.origin, target.global_transform.origin) * melee_knockback
				target.take_damage(midpoint, self.global_transform.basis.z, melee_damage)

func die():
	.die()
	player.increase_heart_rate(kill_hr_reward)
	for n in range(kill_blood_reward):
		Utils.instantiate(blood_pickup, self.global_transform.origin + Vector3.UP, Vector3.UP)
	
