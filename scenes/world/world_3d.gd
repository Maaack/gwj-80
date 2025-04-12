extends Node3D

signal level_won

var level_state : LevelState

func _check_objectives_completed() -> bool:
	return false

func _check_level_won() -> void:
	if _check_objectives_completed():
		level_won.emit()

func _ready():
	level_state = GameState.get_level_state(scene_file_path)

func _exit_tree():
	GlobalState.save()
