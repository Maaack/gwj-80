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
	SlimeType.YINYANG: "uid://bcjfkq2kbbyrr",
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


static var slime_type_descriptions: Dictionary[SlimeType, String] = {
	SlimeType.WATER: "Like the current of a river, water slimes push nearby slimes in the direction they are moving.  This makes them slow to change direction when they gather in groups.",
	SlimeType.FIRE: "Fire slimes are fast moving creatures that rely on each other to stay warm.  They will cause other nearby slimes to grow larger, but will shrink if they are isolated from the group for too long.",
	SlimeType.VINE: "Vine slimes seem to have a strong connection to water slimes.  If they remain close to one for long enough, they grow larger.",
	SlimeType.ROCK: "Rock slimes don't move very fast on their own, and they are also hard for other things to move.",
	SlimeType.EXPLOSIVE: "Explosive slimes live brief but vibrant existences, as they explode shortly after creation, which launches nearby slimes away!",
	SlimeType.METAL: "Metal slimes rely on other creatures to move them, as they are unable to move on their own.",
	SlimeType.ASH: "Ash slimes are mischievous creatures that occasionally like to frighten other slimes, causing them to scatter.",
	SlimeType.MOSS: "Eco slimes grow larger over time.  Once they are fully grown they share their energy with nearby slimes, causing them to grow larger as well.  Sometimes they even take inspiration from a nearby slime, and create a copy of it!",
	SlimeType.MUD: "Mud slimes cause the ground around them to be difficult for other slimes to traverse, which slows nearby slimes down.",
	SlimeType.CRYSTAL: "Crystal slimes are social creatures that encourage nearby slimes to cluster together more tightly.",
	SlimeType.YINYANG: "Balance slimes, being difficult to create, are somewhat rare.  They will occasionally compel nearby slimes to try to make a circle around them.",
}


static var slime_type_icons: Dictionary[SlimeType, String] = {
	SlimeType.WATER: "uid://bqoaoiy523b8r",
	SlimeType.FIRE: "uid://bn03fhhnru5xa",
	SlimeType.VINE: "uid://vf7ojp3gblq5",
	SlimeType.ROCK: "uid://cr2oj3p16ccds",
	SlimeType.EXPLOSIVE: "uid://c0aphyrpahl1k",
	SlimeType.METAL: "uid://woxi0xeh7vbd",
	SlimeType.ASH: "uid://du5g8wy5k6ihe",
	SlimeType.MOSS: "uid://baydccatgwhyf",
	SlimeType.MUD: "uid://jtae8rr2box6",
	SlimeType.CRYSTAL: "uid://b8t36wiqmismf",
	SlimeType.YINYANG: "uid://r1tdjetsw6hv",
}


static var slime_type_sketches: Dictionary[SlimeType, String] = {
	SlimeType.WATER: "uid://p54mdr5bb81s",
	SlimeType.FIRE: "uid://hcolfyvfgp6j",
	SlimeType.VINE: "uid://cwxj4jbdurvoa",
	SlimeType.ROCK: "uid://bvq1su1lfwwcc",
	SlimeType.EXPLOSIVE: "uid://c3tpp7bjikdq3",
	SlimeType.METAL: "uid://c0pm6l5ycafjn",
	SlimeType.ASH: "uid://csb7onfgbcncc",
	SlimeType.MOSS: "uid://406hpilypkq6",
	SlimeType.MUD: "uid://b40vi3fdccxq1",
	SlimeType.CRYSTAL: "uid://kb26c2a6lctj",
	SlimeType.YINYANG: "uid://l0inbdk3oqyj",
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


static func get_slime_description(slime_type: SlimeType) -> String:
	if slime_type not in slime_type_descriptions: return "A default slime."
	return slime_type_descriptions[slime_type]


static func get_slime_icon(slime_type: SlimeType) -> Texture2D:
	if slime_type not in slime_type_icons: return load("uid://drupexiewywk6")
	var icon_path: String = slime_type_icons[slime_type]
	return load(icon_path)


static func get_slime_sketch(slime_type: SlimeType) -> Texture2D:
	if slime_type not in slime_type_sketches: return load("uid://p54mdr5bb81s")
	var icon_path: String = slime_type_sketches[slime_type]
	return load(icon_path)


static func get_relevant_combinations(slime_type: SlimeType) -> Array[SlimeCombination]:
	var relevant_combinations: Array[SlimeCombination] = []

	for combination: SlimeCombination in combinations:
		if combination.has_slime(slime_type):
			relevant_combinations.append(combination)

	return relevant_combinations
