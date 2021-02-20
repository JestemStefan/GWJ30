extends KinematicBody
class_name Entity

# Config
export var health: int

var mesh_mats: Array = []
var meshes: Array = []
onready var damage_flash_mat: SpatialMaterial = preload("res://GR_assets/Enemies/HitFlash.material")
onready var blood_glob = preload("res://GR_assets/Effects/bloodglob/BloodGlob.tscn")
onready var blood_hit = preload("res://GR_assets/Effects/bloodhit/BloodHit.tscn")


var hit_timer: Timer = null
var dead: bool = false

func _ready():
	# Create a timer used for the damage flash and death delay
	hit_timer = Timer.new()
	add_child(hit_timer)
	hit_timer.connect("timeout", self, "hit_timer_timeout")
	hit_timer.set_wait_time(0.1)
	hit_timer.one_shot = true
	# Save a copy of all the materials used for this entity
	recursive_mesh_find(self)

func recursive_mesh_find(node):
	for child in node.get_children():
		if child is MeshInstance:
			meshes.append(child)
			mesh_mats.append(child.get_surface_material(0))
		if child.get_child_count() > 0:
			recursive_mesh_find(child)

func do_damage_flash(flashing: bool, mat_index = 0):
	for index in meshes.size():
		if flashing:
			if meshes[index].get_surface_material_count() > mat_index:
				meshes[index].set_surface_material(mat_index, damage_flash_mat)
		else:
			if meshes[index].get_surface_material_count() > mat_index:
				meshes[index].set_surface_material(mat_index, mesh_mats[index])

func take_damage(point, normal, damage):
	Utils.instantiate(blood_hit, point, normal, 6.0)
	health -= damage
	do_damage_flash(true)
	hit_timer.start()

func hit_timer_timeout():
	do_damage_flash(false)
	if health <= 0 and not dead:
		die()

func die():
	var pos = self.global_transform.origin + Vector3.UP
	var dir = self.global_transform.basis.z
	Utils.instantiate(blood_glob, pos, dir, 2.0)
	Utils.instantiate(blood_glob, pos, dir, 2.0)
	Utils.instantiate(blood_glob, pos, dir, 2.0)
	dead = true
	pass
