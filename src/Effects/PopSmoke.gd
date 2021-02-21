extends Particles

func _ready():
	pass


func _on_Lifetime_timeout():
	call_deferred("free")
