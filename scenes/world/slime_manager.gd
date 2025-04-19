class_name SlimeManager
extends Node

@export var slime_spawners : Array[SlimeSpawner]
@export var slime_type_target : Dictionary[Constants.SlimeType, int]
@export_range(0, 30) var respawn_delay : float = 10.0
var slimes_type_count : Dictionary[Constants.SlimeType, int]

func refresh_slime_spawns() -> void:
	for slime_type in slime_type_target:
		var target_value := slime_type_target[slime_type]
		var current_value := 0
		if slime_type in slimes_type_count:
			current_value = slimes_type_count[slime_type]
		var spawner = _get_spawn_of_type(slime_type)
		var add_count = target_value - current_value - spawner.queued_to_spawn
		if add_count > 0:
			spawner.queue_spawn(add_count)

func _get_spawn_of_type(slime_type : Constants.SlimeType) -> SlimeSpawner:
	for slime_spawner in slime_spawners:
		if slime_spawner.slime_type == slime_type:
			return slime_spawner
	push_warning("No slime of type %d" % slime_type)
	return null

func slime_added(slime_type : Constants.SlimeType, count : int = 1) -> void:
	if slime_type not in slimes_type_count:
		slimes_type_count[slime_type] = 0
	slimes_type_count[slime_type] += count

func slime_removed(slime_type : Constants.SlimeType, count : int = 1) -> void:
	if slime_type not in slimes_type_count:
		slimes_type_count[slime_type] = 0
	slimes_type_count[slime_type] -= count
	if respawn_delay > 0:
		await get_tree().create_timer(respawn_delay, true).timeout
	refresh_slime_spawns()

func slime_masses_removed(slime_mass_types : Dictionary[Constants.SlimeType, int] = {}) -> void:
	for slime_type in slime_mass_types:
		slime_removed(slime_type, slime_mass_types[slime_type])

func _ready():
	await get_tree().create_timer(1.0).timeout
	refresh_slime_spawns()
