@tool
extends Node

@export var size_index : int = 1 :
	set(value):
		if csg_boxes.size() > 0:
			size_index = value % csg_boxes.size()
			_refresh_world()
@export var csg_boxes : Array[CSGBox3D]
@export var baked_collision_shapes : Array[CollisionShape3D]
@export var distances : Array[float]
@export var water_spawn : SlimeSpawner
@export var fire_spawn : SlimeSpawner
@export var vine_spawn : SlimeSpawner
@export var rock_spawn : SlimeSpawner

func _refresh_world():
	var iter : int = 0
	for csg_box in csg_boxes:
		if iter == size_index:
			csg_box.show()
		else:
			csg_box.hide()
		iter += 1
	iter = 0
	for shape in baked_collision_shapes:
		if iter == size_index:
			shape.disabled = false
		else:
			shape.disabled = true
		iter += 1
	var distance_index = size_index % distances.size()
	var distance = distances[distance_index]
	water_spawn.position.x = distance
	water_spawn.position.z = -distance
	fire_spawn.position.x = -distance
	fire_spawn.position.z = -distance
	vine_spawn.position.x = -distance
	vine_spawn.position.z = distance
	rock_spawn.position.x = distance
	rock_spawn.position.z = distance

func _input(event):
	if event.is_action_pressed("test_map_size"):
		size_index += 1
