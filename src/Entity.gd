extends KinematicBody
class_name Entity

# Config
export var health: int

var mesh_mats: Array = []
var meshes: Array = []
onready var damage_flash_mat: SpatialMaterial = preload("res://GR_assets/Enemies/HitFlash.material")

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

func do_damage_flash(flashing: bool, mat_index = 0):
	for index in meshes.size():
		if flashing:
			if meshes[index].get_surface_material_count() > mat_index:
				meshes[index].set_surface_material(mat_index, damage_flash_mat)
		else:
			if meshes[index].get_surface_material_count() > mat_index:
				meshes[index].set_surface_material(mat_index, mesh_mats[index])

func take_damage(point, normal, damage):
	Utils.instantiate(load("res://GR_assets/Effects/bloodhit/BloodHit.tscn"), point, normal, 6.0)
	health -= damage
	do_damage_flash(true)
	yield(get_tree().create_timer(0.075), "timeout")
	do_damage_flash(false)
	if health <= 0:
		die()

func die():
	pass
