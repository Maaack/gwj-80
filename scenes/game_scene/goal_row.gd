@tool
class_name GoalsRow
extends HBoxContainer

const GOAL_TEXT : String = "%d / %d"

@export var slime_count : int = 0 :
	set(value):
		slime_count = value
		if is_inside_tree():
			_slime_count_label.text = GOAL_TEXT % [slime_count, slime_goal]
@export var slime_goal : int = 1 :
	set(value):
		slime_goal = value
		if is_inside_tree():
			_slime_count_label.text = GOAL_TEXT % [slime_count, slime_goal]
@export var slime_name : String = "Any":
	set(value):
		slime_name = value
		if is_inside_tree():
			_slime_name_label.text = slime_name
@export var slime_icon : Texture2D:
	set(value):
		slime_icon = value
		if is_inside_tree():
			_texture_rect.texture = slime_icon

@onready var _slime_count_label : Label = $SlimeCountLabel
@onready var _slime_name_label : Label = $SlimeNameLabel
@onready var _texture_rect : TextureRect = $TextureRect
