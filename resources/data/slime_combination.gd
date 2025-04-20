class_name SlimeCombination
extends Resource

@export var slime_1 : Constants.SlimeType
@export var slime_2 : Constants.SlimeType
@export var slime_result : Constants.SlimeType


func has_slime(slime_type: Constants.SlimeType) -> bool:
	return slime_type == slime_1 or slime_type == slime_2 or slime_type == slime_result
