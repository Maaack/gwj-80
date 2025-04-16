class_name JournalState
extends Resource

@export var slimes : Array[Constants.SlimeType]
@export var combinations : Array[SlimeCombination]

func add_slime(slime_type : Constants.SlimeType) -> void:
	if slime_type not in slimes:
		slimes.append(slime_type)

func add_combination(combination : SlimeCombination) -> void:
	if combination not in combinations:
		combinations.append(combination)
		
