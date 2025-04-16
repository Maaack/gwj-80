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
	SlimeCombination.new(SlimeType.WATER, SlimeType.FIRE, SlimeType.EXPLOSIVE),
	SlimeCombination.new(SlimeType.WATER, SlimeType.VINE, SlimeType.MOSS),
	SlimeCombination.new(SlimeType.WATER, SlimeType.ROCK, SlimeType.MUD),
	SlimeCombination.new(SlimeType.VINE, SlimeType.FIRE, SlimeType.ASH),
	SlimeCombination.new(SlimeType.ROCK, SlimeType.FIRE, SlimeType.METAL),
	SlimeCombination.new(SlimeType.VINE, SlimeType.ROCK, SlimeType.CRYSTAL),
	SlimeCombination.new(SlimeType.MOSS, SlimeType.FIRE, SlimeType.EXPLOSIVE),
	SlimeCombination.new(SlimeType.MOSS, SlimeType.ROCK, SlimeType.EXPLOSIVE),
	SlimeCombination.new(SlimeType.MUD, SlimeType.FIRE, SlimeType.EXPLOSIVE),
	SlimeCombination.new(SlimeType.MUD, SlimeType.VINE, SlimeType.EXPLOSIVE),
	SlimeCombination.new(SlimeType.ASH, SlimeType.WATER, SlimeType.EXPLOSIVE),
	SlimeCombination.new(SlimeType.ASH, SlimeType.ROCK, SlimeType.EXPLOSIVE),
	SlimeCombination.new(SlimeType.METAL, SlimeType.WATER, SlimeType.EXPLOSIVE),
	SlimeCombination.new(SlimeType.METAL, SlimeType.VINE, SlimeType.EXPLOSIVE),
	SlimeCombination.new(SlimeType.CRYSTAL, SlimeType.EXPLOSIVE, SlimeType.YINYANG),
]
