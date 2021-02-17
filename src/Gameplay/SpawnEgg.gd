extends Spatial

export(PackedScene) var creature_1
export(PackedScene) var creature_2
func _ready():
	pass

func _on_Timer_timeout():
	if randi() % 3 == 0:
		Utils.instantiate(creature_2, self.global_transform.origin, Vector3.FORWARD)
	else:
		Utils.instantiate(creature_1, self.global_transform.origin, Vector3.FORWARD)
