class_name Constants
extends Node

enum SlimeType {
	NONE,
	WATER, # FLOODING CHAOS
	FIRE, # BURNING CHAOS
	VINE, # GROWING CHAOS
	ROCK, # PERSISTENT CHAOS
	EXPLOSIVE, # CHAOTIC CHAOS
	METAL, # HARDENED CHAOS
	ASH, # DEATH CHAOS
	MOSS, # LIFE CHAOS
	MUD, # GRIPPING CHAOS
	CRYSTAL, # ORDERING CHAOS
	YINYANG, # BALANCED CHAOS
}

static var combinations : Array[SlimeCombination] = [
	new_slime_combination(SlimeType.WATER, SlimeType.FIRE, SlimeType.EXPLOSIVE),
	new_slime_combination(SlimeType.WATER, SlimeType.VINE, SlimeType.MOSS),
	new_slime_combination(SlimeType.WATER, SlimeType.ROCK, SlimeType.MUD),
	new_slime_combination(SlimeType.VINE, SlimeType.FIRE, SlimeType.ASH),
	new_slime_combination(SlimeType.ROCK, SlimeType.FIRE, SlimeType.METAL),
	new_slime_combination(SlimeType.VINE, SlimeType.ROCK, SlimeType.CRYSTAL),
	new_slime_combination(SlimeType.MOSS, SlimeType.FIRE, SlimeType.EXPLOSIVE),
	new_slime_combination(SlimeType.MOSS, SlimeType.ROCK, SlimeType.EXPLOSIVE),
	new_slime_combination(SlimeType.MUD, SlimeType.FIRE, SlimeType.EXPLOSIVE),
	new_slime_combination(SlimeType.MUD, SlimeType.VINE, SlimeType.EXPLOSIVE),
	new_slime_combination(SlimeType.ASH, SlimeType.WATER, SlimeType.EXPLOSIVE),
	new_slime_combination(SlimeType.ASH, SlimeType.ROCK, SlimeType.EXPLOSIVE),
	new_slime_combination(SlimeType.METAL, SlimeType.WATER, SlimeType.EXPLOSIVE),
	new_slime_combination(SlimeType.METAL, SlimeType.VINE, SlimeType.EXPLOSIVE),
	new_slime_combination(SlimeType.CRYSTAL, SlimeType.EXPLOSIVE, SlimeType.YINYANG),
]

static var slime_type_scenes : Dictionary[SlimeType, String] = {
	SlimeType.WATER: "uid://dc01qmly3uoig",
	SlimeType.FIRE: "uid://dppp4c2wn6eny",
	SlimeType.VINE: "uid://c6w5jfswaercw",
	SlimeType.ROCK: "uid://xa7j2wqcqeyr",
	SlimeType.EXPLOSIVE: "uid://dtollnkgrdph8",
	SlimeType.METAL: "uid://b5iybcpovkwdx",
	SlimeType.ASH: "uid://rsvs5gnqqr8d",
	SlimeType.MOSS: "uid://d3hfsb384hf32",
	SlimeType.MUD: "uid://hb7xi8e15pp6",
	SlimeType.CRYSTAL: "uid://dbm1nj4nxxm1f",
	SlimeType.YINYANG: "uid://rsvs5gnqqr8d",
}

static var slime_type_names : Dictionary[SlimeType, String] = {
	SlimeType.WATER: "Water",
	SlimeType.FIRE: "Fire",
	SlimeType.VINE: "Vine",
	SlimeType.ROCK: "Rock",
	SlimeType.EXPLOSIVE: "Explosive",
	SlimeType.METAL: "Metal",
	SlimeType.ASH: "Ash",
	SlimeType.MOSS: "Eco",
	SlimeType.MUD: "Mud",
	SlimeType.CRYSTAL: "Crystal",
	SlimeType.YINYANG: "Balance",
}


# TODO: Update UIDs to use the real icons.
static var slime_type_icons: Dictionary[SlimeType, String] = {
	SlimeType.WATER: "uid://drupexiewywk6",
	SlimeType.FIRE: "uid://drupexiewywk6",
	SlimeType.VINE: "uid://drupexiewywk6",
	SlimeType.ROCK: "uid://drupexiewywk6",
	SlimeType.EXPLOSIVE: "uid://drupexiewywk6",
	SlimeType.METAL: "uid://drupexiewywk6",
	SlimeType.ASH: "uid://drupexiewywk6",
	SlimeType.MOSS: "uid://drupexiewywk6",
	SlimeType.MUD: "uid://drupexiewywk6",
	SlimeType.CRYSTAL: "uid://drupexiewywk6",
	SlimeType.YINYANG: "uid://drupexiewywk6",
}

static func new_slime_combination(slime_1 : SlimeType, slime_2 : SlimeType, slime_result : SlimeType) -> SlimeCombination:
	var slime_combination : = SlimeCombination.new()
	slime_combination.slime_1 = slime_1
	slime_combination.slime_2 = slime_2
	slime_combination.slime_result = slime_result
	return slime_combination

static func get_slime_instance(slime_type : SlimeType) -> Slime:
	if slime_type not in slime_type_scenes: return
	var slime_path := slime_type_scenes[slime_type]
	var slime_scene : PackedScene = load(slime_path)
	return slime_scene.instantiate()

static func get_slime_name(slime_type : SlimeType) -> String:
	if slime_type not in slime_type_names: return "Any"
	return slime_type_names[slime_type]


static func get_slime_icon(slime_type: SlimeType) -> Texture2D:
	if slime_type not in slime_type_icons: return load("uid://drupexiewywk6")
	var icon_path: String = slime_type_icons[slime_type]
	return load(icon_path)


static func get_relevant_combinations(slime_type: SlimeType) -> Array[SlimeCombination]:
	var relevant_combinations: Array[SlimeCombination] = []

	for combination: SlimeCombination in combinations:
		if combination.has_slime(slime_type):
			relevant_combinations.append(combination)

	return relevant_combinations
