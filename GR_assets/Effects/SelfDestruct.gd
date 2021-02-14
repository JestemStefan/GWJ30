extends Spatial

export var lifetime : float = 1.0
var _timer

func _ready():
	# Set up timer for self destruct
	_timer = Timer.new()
	add_child(_timer)
	_timer.connect("timeout", self, "_on_Timer_timeout")
	_timer.set_wait_time(lifetime)
	_timer.start()
	for child in self.get_children():
		if child is Particles:
			child.emitting = true

func _on_Timer_timeout():
	self.queue_free()
