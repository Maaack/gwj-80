extends Control

@onready var _goals_mini_panel : GoalsMiniPanel = %GoalsMiniPanel
@onready var _level_loader : LevelListLoader = $LevelLoader

var pc : PlayerCharacter

func _on_level_loader_level_loaded() -> void:
	var current_level : GameLevel = _level_loader.current_level
	if current_level == null: return
	await current_level.ready
	pc = current_level.pc
	current_level.slime_delivered.connect(_on_slimes_delivered)
	_goals_mini_panel.objective_list = current_level.objective_list

func _on_slimes_delivered(slime_type: Constants.SlimeType, total_delivered: int) -> void:
	_goals_mini_panel.delivered_list[slime_type] = total_delivered
	_goals_mini_panel.refresh_objectives()

func _on_journal_panel_journal_closed() -> void:
	pc.is_journaling = false

func _on_journal_panel_journal_opened() -> void:
	pc.is_journaling = true
