extends MeshInstance
class_name Flying_Nav

var area_size: Vector3

func _ready():
	randomize()
	area_size = get_aabb().size * 0.5

func generate_nav_point():
	randomize()
	var random_point = global_transform.origin + Vector3(rand_range(-area_size.x, area_size.x), 
															rand_range(-area_size.y, area_size.y),
															rand_range(-area_size.z, area_size.z))
	return random_point
