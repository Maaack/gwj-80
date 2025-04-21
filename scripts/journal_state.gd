class_name JournalState
extends Resource


signal slime_discovered(slime_type: Constants.SlimeType)

@export var slimes : Array[Constants.SlimeType]
@export var combinations : Array[SlimeCombination]
@export var slime_progress : Dictionary[Constants.SlimeType, float]

func add_slime(slime_type : Constants.SlimeType) -> void:
	if slime_type not in slimes:
		slimes.append(slime_type)
		slime_discovered.emit(slime_type)

func add_combination(combination : SlimeCombination) -> void:
	if combination not in combinations:
		combinations.append(combination)

func add_slime_progress(slime_type : Constants.SlimeType, progress : float) -> void:
	if slime_type not in slime_progress:
		slime_progress[slime_type] = 0.0
	if slime_progress[slime_type] >= 1.0:
		return
	slime_progress[slime_type] += progress
	if slime_progress[slime_type] >= 1.0:
		add_slime(slime_type)

func get_slime_progress(slime_type : Constants.SlimeType) -> float:
	if slime_type not in slime_progress:
		return 0.0
	return slime_progress[slime_type]

func has_slime(slime_type : Constants.SlimeType) -> bool:
	return slime_type in slimes
