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

static func new_slime_combination(slime_1 : SlimeType, slime_2 : SlimeType, slime_result : SlimeType) -> SlimeCombination:
	var slime_combination : = SlimeCombination.new()
	slime_combination.slime_1 = slime_1
	slime_combination.slime_2 = slime_2
	slime_combination.slime_result = slime_result
	return slime_combination
