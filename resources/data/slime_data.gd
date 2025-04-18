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

func get_random_type_masses(target_mass := 1) -> Dictionary[Constants.SlimeType, int]:
	var random_type_masses : Dictionary[Constants.SlimeType, int]
	var total_random_mass : int = 0
	for slime_type in slime_type_masses:
		var remaining_mass = target_mass - total_random_mass
		var random_mass = randi() % (slime_type_masses[slime_type] + 1)
		if random_mass == 0: continue
		random_type_masses[slime_type] = random_mass
		total_random_mass += random_mass
		if total_random_mass >= target_mass : break
	return random_type_masses

func subtract_type_masses(type_masses : Dictionary[Constants.SlimeType, int]) -> void:
	for slime_type in type_masses:
		if slime_type not in slime_type_masses: continue
		slime_type_masses[slime_type] -= type_masses[slime_type]
		if slime_type_masses[slime_type] <= 0:
			slime_type_masses.erase(slime_type)
