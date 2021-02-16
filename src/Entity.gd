extends KinematicBody
class_name Entity

export var health: int

onready var damage_flash_mat: SpatialMaterial = preload("res://GR_assets/Enemies/HitFlash.material")
var mesh_mats: Array = []
var meshes: Array = []

func _ready():
	# Save a copy of all the materials used for this entity
	recursive_mesh_find(self)

func recursive_mesh_find(node):
	for child in node.get_children():
		if child is MeshInstance:
			meshes.append(child)
			mesh_mats.append(child.get_surface_material(0))
		if child.get_child_count() > 0:
			recursive_mesh_find(child)

func do_damage_flash(flashing: bool):
	for index in meshes.size():
		if flashing:
			meshes[index].set_surface_material(0, damage_flash_mat)
		else:
			meshes[index].set_surface_material(0, mesh_mats[index])

func take_damage(point, normal, damage):
	Utils.instantiate(load("res://GR_assets/Effects/bloodhit/BloodHit.tscn"), self.global_transform.origin, self.global_transform.basis.z, 12.0)
	health -= damage
	do_damage_flash(true)
	yield(get_tree().create_timer(0.1), "timeout")
	do_damage_flash(false)
	if health <= 0:
		die()

func die():
	var blood_glob = load("res://GR_assets/Effects/bloodglob/BloodGlob.tscn")
	var blood_hit = load("res://GR_assets/Effects/bloodhit/BloodHit.tscn")
	var blood_pickup = load("res://GR_assets/Gameplay/BloodPickup.tscn")
	Utils.instantiate(blood_pickup, self.global_transform.origin + Vector3.UP, Vector3.UP)
	Utils.instantiate(blood_pickup, self.global_transform.origin + Vector3.UP, Vector3.UP)
	Utils.instantiate(blood_pickup, self.global_transform.origin + Vector3.UP, Vector3.UP)
	Utils.instantiate(blood_glob, self.global_transform.origin + Vector3.UP, Vector3.UP, 3.0)
	Utils.instantiate(blood_glob, self.global_transform.origin + Vector3.UP, Vector3.UP, 3.0)
	Utils.instantiate(blood_hit, self.global_transform.origin, self.global_transform.basis.z, 8.0)
	pass
