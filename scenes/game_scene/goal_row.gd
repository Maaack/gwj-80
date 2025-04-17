@tool
class_name GoalsRow
extends HBoxContainer

@export var slime_count : int = 1 :
	set(value):
		slime_count = value
		if is_inside_tree():
			_slime_count_label.text = "%dx" % slime_count
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
