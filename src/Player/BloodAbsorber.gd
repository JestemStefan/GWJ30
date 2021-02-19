extends Area

var blood_in_range: Array = []
var player

func _ready():
	player = get_tree().get_nodes_in_group("Player")[0]

func _physics_process(delta):
	for blood in blood_in_range:
		var dist = blood.global_transform.origin.distance_to(player.global_transform.origin + Vector3.UP * 2)
		#blood.add_central_force(blood.global_transform.origin.direction_to(player.global_transform.origin) * (10.0 - dist) * 20.0)
		var bgto = blood.global_transform.origin
		var pgto = player.global_transform.origin + Vector3.UP
		blood.global_transform.origin = lerp(bgto, pgto, (10.0 - dist) * delta)
		if blood.global_transform.origin.distance_to(player.global_transform.origin + Vector3.UP * 2) < 2.0:
			blood.queue_free()
			_on_BloodAbsorb_body_exited(blood)
			player.blood += 3
			player.hud.set_blood(player.blood)

func _on_BloodAbsorb_body_entered(body):
	blood_in_range.append(body)
	body.mode = RigidBody.MODE_KINEMATIC

func _on_BloodAbsorb_body_exited(body):
	if blood_in_range.has(body):
		blood_in_range.remove(blood_in_range.find(body))
		body.mode = RigidBody.MODE_RIGID
