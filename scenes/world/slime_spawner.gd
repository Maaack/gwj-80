class_name SlimeSpawner
extends Node3D

signal slime_spawned(slime_node : Slime)

@export var slime_type : Constants.SlimeType
@export_range(0, 10) var spawn_radius : float = 2.5
@export_range(0, 10) var spawn_delay : float = 0.5
@export_range(0, 10) var spawn_duration : float = 1.0
@export_range(1, 10) var max_spawn_mass : int = 5
@export var queued_to_spawn : int = 0
@export var spawn_offset : Vector3 = Vector3(0, 1, 0)

@onready var _spawn_timer : Timer = $SpawnTimer

func spawn(slime_mass : int = 1):
	var slime_instance : Slime = Constants.get_slime_instance(slime_type)
	if slime_instance == null:
		push_error("No instance created for slime type %d" % slime_type)
	var rand_angle = randf_range(0, 2 * PI)
	var rand_distance = randf_range(0, spawn_radius)
	var normal_vector = Vector2.from_angle(rand_angle)
	slime_instance.position = Vector3(normal_vector.x, 0, normal_vector.y) * rand_distance
	slime_instance.position += spawn_offset
	add_child(slime_instance)
	slime_instance.grow(slime_mass)
	slime_instance.set_data_type_masses()
	slime_spawned.emit(slime_instance)
	slime_instance.scale = Vector3.ONE * 0.01
	var tween = create_tween()
	tween.tween_property(slime_instance, "scale", Vector3.ONE, spawn_duration)

func _process_queue():
	if not _spawn_timer or not _spawn_timer.is_stopped(): return
	if queued_to_spawn < 1: return
	var max_mass : int = min(queued_to_spawn, max_spawn_mass)
	var final_mass = (randi() % max_mass) + 1
	spawn(final_mass)
	queued_to_spawn -= final_mass
	_spawn_timer.start(spawn_delay)

func queue_spawn(count : int = 1):
	queued_to_spawn += count
	_process_queue()

func _on_spawn_timer_timeout():
	_process_queue()

func _ready():
	_process_queue.call_deferred()
