extends Node3D

signal level_won

@export var objective_list : ObjectiveList

var level_state : LevelState
var slimes_submitted : Dictionary[Constants.SlimeType, int] = {}

func _check_objectives_completed() -> bool:
	for objective_data in objective_list.objectives:
		var slime_type = objective_data.slime_type
		if not slimes_submitted.has(slime_type):
			return false
		if slimes_submitted[slime_type] < objective_data.slime_count:
			return false
	return true

func _check_level_won() -> void:
	if _check_objectives_completed():
		level_won.emit()

func _on_slime_submitted(slime_data : SlimeData):
	if not slimes_submitted.has(slime_data.slime_type):
		slimes_submitted[slime_data.slime_type] = 0
	slimes_submitted[slime_data.slime_type] += 1
	_check_level_won()

func _ready():
	level_state = GameState.get_level_state(scene_file_path)

func _exit_tree():
	GlobalState.save()
