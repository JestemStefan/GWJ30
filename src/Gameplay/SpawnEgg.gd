extends Spatial

export(PackedScene) var creature_1

func _ready():
	pass

func _on_Timer_timeout():
	Utils.instantiate(creature_1, self.global_transform.origin, Vector3.FORWARD)
