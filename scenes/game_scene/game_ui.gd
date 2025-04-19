extends Control

@onready var _goals_mini_panel : GoalsMiniPanel = %GoalsMiniPanel
@onready var _level_loader : LevelListLoader = $LevelLoader

var pc : PlayerCharacter

func _on_level_loader_level_loaded():
	var current_level : GameLevel = _level_loader.current_level
	if current_level == null: return
	await current_level.ready
	pc = current_level.pc
	_goals_mini_panel.objective_list = current_level.objective_list

func _on_journal_panel_journal_closed():
	pc.is_journaling = false

func _on_journal_panel_journal_opened():
	pc.is_journaling = true
