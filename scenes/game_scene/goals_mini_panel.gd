@tool
class_name GoalsMiniPanel
extends PanelContainer


@export var objective_list : ObjectiveList :
	set(value):
		objective_list = value
		delivered_list.clear()
		if is_inside_tree():
			refresh_objectives()
@export var delivered_list : Dictionary[Constants.SlimeType, int]

@onready var _goals_container : BoxContainer = %GoalsContainer
@onready var _goal_row : BoxContainer = $GoalRow

func get_total_delivered() -> int:
	var total_delivered : int = 0
	for slime_type in delivered_list:
		total_delivered += delivered_list[slime_type]
	return total_delivered

func refresh_objectives() -> void:
	for child in _goals_container.get_children():
		child.queue_free()
	for goal in objective_list.objectives:
		if goal is ObjectiveData:
			var goal_row : GoalsRow = _goal_row.duplicate()
			_goals_container.add_child(goal_row)
			goal_row.visible = true
			goal_row.slime_goal = goal.slime_count
			if goal.slime_type == Constants.SlimeType.NONE:
				goal_row.slime_count = get_total_delivered()
			elif goal.slime_type in delivered_list:
				goal_row.slime_count = delivered_list[goal.slime_type]
			else:
				goal_row.slime_count = 0
			goal_row.slime_name = Constants.get_slime_name(goal.slime_type)
			goal_row.slime_icon = Constants.get_slime_icon(goal.slime_type)
