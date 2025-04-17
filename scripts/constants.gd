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
	SlimeType.MOSS: "uid://rsvs5gnqqr8d",
	SlimeType.MUD: "uid://hb7xi8e15pp6",
	SlimeType.CRYSTAL: "uid://dbm1nj4nxxm1f",
	SlimeType.YINYANG: "uid://rsvs5gnqqr8d",
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
