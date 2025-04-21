class_name SlimeCombinationDisplay
extends HBoxContainer


const SILHOUETTE_COLOR := Color("181818")

var slime_combination: SlimeCombination : set = _set_slime_combination

@onready var slime_one_label: Label = %SlimeOneLabel
@onready var slime_one_texture: TextureRect = %SlimeOneTexture

@onready var slime_two_label: Label = %SlimeTwoLabel
@onready var slime_two_texture: TextureRect = %SlimeTwoTexture

@onready var result_label: Label = %ResultLabel
@onready var result_texture: TextureRect = %ResultTexture


func _set_slime_combination(new_combination: SlimeCombination) -> void:
	var journal_state: JournalState = GameState.get_journal_state()

	if journal_state.get_slime_progress(new_combination.slime_1) > 0.0:
		slime_one_label.text = Constants.get_slime_name(new_combination.slime_1)
		slime_one_texture.texture = Constants.get_slime_icon(new_combination.slime_1)
		slime_one_texture.self_modulate = Color.WHITE
	else:
		slime_one_label.text = "? ? ?"
		slime_one_texture.self_modulate = SILHOUETTE_COLOR

	if journal_state.get_slime_progress(new_combination.slime_2) > 0.0:
		slime_two_label.text = Constants.get_slime_name(new_combination.slime_2)
		slime_two_texture.texture = Constants.get_slime_icon(new_combination.slime_2)
		slime_two_texture.self_modulate = Color.WHITE
	else:
		slime_two_label.text = "? ? ?"
		slime_two_texture.self_modulate = SILHOUETTE_COLOR

	if journal_state.get_slime_progress(new_combination.slime_result) > 0.0:
		result_label.text = Constants.get_slime_name(new_combination.slime_result)
		result_texture.texture = Constants.get_slime_icon(new_combination.slime_result)
		result_texture.self_modulate = Color.WHITE
	else:
		result_label.text = "? ? ?"
		result_texture.self_modulate = SILHOUETTE_COLOR
