class_name SlimeData
extends Resource

@export var slime_type : Constants.SlimeType
@export var slime_mass : int = 1
@export var slime_type_masses : Dictionary[Constants.SlimeType, int]

func get_slime_type_masses() -> Dictionary[Constants.SlimeType, int]:
	if slime_type_masses.size() > 0:
		return slime_type_masses
	else:
		var slime_type_mass : Dictionary[Constants.SlimeType, int] = {}
		slime_type_mass[slime_type] = slime_mass
		return slime_type_mass

func get_true_mass() -> int:
	var total_mass : int = 0
	if slime_type_masses.size() > 0:
		for slime_type in slime_type_masses:
			total_mass += slime_type_masses[slime_type]
	return total_mass
