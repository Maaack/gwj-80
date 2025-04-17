@tool
class_name GoalsMiniPanel
extends PanelContainer

const GOAL_TEXT : String = "%dx"

@export var objective_list : ObjectiveList :
	set(value):
		objective_list = value
		if is_inside_tree():
			_refresh_objectives()

@onready var _goals_container : BoxContainer = %GoalsContainer
@onready var _goal_row : BoxContainer = $GoalRow

func _refresh_objectives() -> void:
	for child in _goals_container.get_children():
		child.queue_free()
	for goal in objective_list.objectives:
		if goal is ObjectiveData:
			var goal_row : GoalsRow = _goal_row.duplicate()
			_goals_container.add_child(goal_row)
			goal_row.visible = true
			goal_row.slime_count = goal.slime_count
			goal_row.slime_name = Constants.get_slime_name(goal.slime_type)
