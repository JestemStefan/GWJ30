extends Area

var blood_in_range: Array = []
var player

func _ready():
	player = get_tree().get_nodes_in_group("Player")[0]

func _physics_process(delta):
	for blood in blood_in_range:
		var dist = blood.global_transform.origin.distance_to(player.global_transform.origin + Vector3.UP * 2)
		blood.add_central_force(blood.global_transform.origin.direction_to(player.global_transform.origin) * (10.0 - dist) * 20.0)
		if blood.global_transform.origin.distance_to(player.global_transform.origin + Vector3.UP * 2) < 2.0:
			blood.queue_free()
			_on_BloodAbsorb_body_exited(blood)
			player.blood += 1

func _on_BloodAbsorb_body_entered(body):
	blood_in_range.append(body)

func _on_BloodAbsorb_body_exited(body):
	if blood_in_range.has(body):
		blood_in_range.remove(blood_in_range.find(body))
