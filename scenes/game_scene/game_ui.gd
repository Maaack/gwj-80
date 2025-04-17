extends Control

@onready var _goals_mini_panel : GoalsMiniPanel = %GoalsMiniPanel
@onready var _level_loader : LevelListLoader = $LevelLoader

func _on_level_loader_level_loaded():
	var current_level : GameLevel = _level_loader.current_level
	if current_level == null: return
	_goals_mini_panel.objective_list = current_level.objective_list
