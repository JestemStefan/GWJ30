extends Spatial

onready var leech = preload("res://GR_assets/Enemies/Leech.tscn")
onready var bigboi = preload("res://GR_assets/Enemies/BigBoi.tscn")
onready var warrior = preload("res://GR_assets/Enemies/Warrior.tscn")
onready var watcher = preload("res://GR_assets/Enemies/Watcher.tscn")

func _on_Timer_timeout():
	var chance = randi() % 6
	if chance <= 1:
		Utils.instantiate(leech, self.global_transform.origin, Vector3.FORWARD)
	elif chance <= 2:
		Utils.instantiate(bigboi, self.global_transform.origin, Vector3.FORWARD)
	elif chance <= 4:
		Utils.instantiate(warrior, self.global_transform.origin, Vector3.FORWARD)
	else:
		Utils.instantiate(watcher, self.global_transform.origin, Vector3.FORWARD)
	if $Timer.wait_time > 3.0:
		$Timer.wait_time -= 0.5
