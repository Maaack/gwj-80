extends Node3D

signal level_won
signal slimes_combined(slime_type_1: Constants.SlimeType, slime_type_2: Constants.SlimeType)

@export var objective_list : ObjectiveList

@onready var delivery_area : DeliveryArea3D = $DeliveryArea3D
@onready var slime_manager : SlimeManager = $SlimeManager

var level_state : LevelState
var slimes_submitted : Dictionary[Constants.SlimeType, int] = {}

func _get_total_slimes_delivered() -> int:
	var total_slimes : int = 0
	for slime_type in slimes_submitted:
		total_slimes += slimes_submitted[slime_type]
	return total_slimes

func _check_objectives_completed() -> bool:
	for objective_data in objective_list.objectives:
		var slime_type = objective_data.slime_type
		if slime_type == Constants.SlimeType.NONE:
			if _get_total_slimes_delivered() < objective_data.slime_count:
				return false
			else:
				continue
		if not slimes_submitted.has(slime_type):
			return false
		if slimes_submitted[slime_type] < objective_data.slime_count:
			return false
	return true

func _check_level_won() -> void:
	if _check_objectives_completed():
		level_won.emit()

func _on_slime_delivered(slime_data : SlimeData):
	if not slimes_submitted.has(slime_data.slime_type):
		slimes_submitted[slime_data.slime_type] = 0
	slimes_submitted[slime_data.slime_type] += 1
	_check_level_won()

func _on_slime_detected():
	$DeliveryDelayTimer.start()

func _on_slime_spawned(slime_node : Slime) -> void:
	slime_node.reparent(self)
	slime_node.slime_touched.connect(_on_slimes_touch.bind(slime_node))
	slime_node.departed.connect(_on_slime_departed.bind(slime_node.slime_data))
	slime_manager.slime_added(slime_node.slime_type)

func _on_slime_departed(slime_data : SlimeData) -> void:
	slime_manager.slime_masses_removed(slime_data.get_slime_type_masses())

func _combine_slime_masses(slime : Slime, other_slime : Slime) -> Dictionary[Constants.SlimeType, int]:
	var slime_type_masses : Dictionary[Constants.SlimeType, int] = slime.slime_data.get_slime_type_masses()
	var other_slime_type_masses : Dictionary[Constants.SlimeType, int] = other_slime.slime_data.get_slime_type_masses()
	for slime_type in other_slime_type_masses:
		if slime_type in slime_type_masses:
			slime_type_masses[slime_type] += other_slime_type_masses[slime_type]
		else:
			slime_type_masses[slime_type] = other_slime_type_masses[slime_type]
	return slime_type_masses

func _on_slimes_touch(slime_1 : Slime, slime_2 : Slime) -> void:
	for combo in Constants.combinations:
		if (slime_1.slime_type == combo.slime_1 and slime_2.slime_type == combo.slime_2) or \
			(slime_2.slime_type == combo.slime_1 and slime_1.slime_type == combo.slime_2):
			slimes_combined.emit(slime_1.slime_type, slime_2.slime_type)
			var total_mass = slime_1.mass + slime_2.mass
			var slime_result = Constants.get_slime_instance(combo.slime_result)
			slime_result.global_position = (slime_1.global_position + slime_2.global_position) / 2
			add_child(slime_result)
			slime_result.slime_data.slime_type_masses = _combine_slime_masses(slime_1, slime_2)
			slime_2.depart(1.0, false)
			slime_1.depart(1.0, false)
			_on_slime_spawned(slime_result)
			slime_result.grow(total_mass, 1.0)
			GameState.get_journal_state().add_combination(combo)

func _on_delivery_delay_timer_timeout():
	delivery_area.deliver()

func _ready():
	level_state = GameState.get_level_state(scene_file_path)
	if delivery_area:
		delivery_area.slime_delivered.connect(_on_slime_delivered)
		delivery_area.slime_detected.connect(_on_slime_detected)
	for child in get_children():
		if child is SlimeSpawner:
			child.slime_spawned.connect(_on_slime_spawned)

func _exit_tree():
	GlobalState.save()
