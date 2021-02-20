extends Spatial

func _ready():
	Globals.scene_root = self
	Engine.time_scale = 1.0
