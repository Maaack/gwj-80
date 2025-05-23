class_name GameLevel
extends Node3D

signal level_won
signal slimes_combined(slime_type_1: Constants.SlimeType, slime_type_2: Constants.SlimeType)
signal slime_delivered(slime_type: Constants.SlimeType, total_delivered: int)

@export var objective_list : ObjectiveList
@export var tutorial_scenes : Array[PackedScene]

@onready var delivery_area : DeliveryArea3D = $DeliveryArea3D
@onready var slime_manager : SlimeManager = $SlimeManager
@onready var pc : PlayerCharacter = %PlayerCharacter3D

var level_state : LevelState
var slimes_submitted : Dictionary[Constants.SlimeType, int] = {}

func _get_total_slimes_delivered() -> int:
	var total_slimes : int = 0
	for slime_type in slimes_submitted:
		total_slimes += slimes_submitted[slime_type]
	return total_slimes

func _check_objectives_completed() -> bool:
	if objective_list == null: return false
	for objective_data in objective_list.objectives:
		var slime_type = objective_data.slime_type
		if slime_type == Constants.SlimeType.NONE:
			if _get_total_slimes_delivered() < objective_data.slime_count:
				return false
			else:
				continue
		if not slimes_submitted.has(slime_type):
			return false
		if slimes_submitted[slime_type] < objective_data.slime_count:
			return false
	return true

func _check_level_won() -> void:
	if _check_objectives_completed():
		level_won.emit()

func _on_slime_delivered(slime_data : SlimeData):
	if not slimes_submitted.has(slime_data.slime_type):
		slimes_submitted[slime_data.slime_type] = 0
	slimes_submitted[slime_data.slime_type] += 1
	slime_delivered.emit(slime_data.slime_type, slimes_submitted[slime_data.slime_type])
	_check_level_won()

func _on_slime_spawned(slime_node : Slime, adds_mass : bool = true) -> void:
	slime_node.reparent(self)
	# Slimes inherit their rotation from the original parent, which causes them to look in the wrong direction.
	# This clears the relevant rotation.
	# NOTE: This is a band-aid fix, it doesn't address the core problem.
	slime_node.rotation.y = 0.0
	slime_node.slime_touched.connect(_on_slimes_touch.bind(slime_node))
	slime_node.departed.connect(_on_slime_departed.bind(slime_node.slime_data))
	slime_node.slime_split.connect(_on_slime_spawned.bind(false))
	if adds_mass:
		slime_manager.slime_added(slime_node.slime_type, slime_node.mass)

func _on_slime_departed(slime_data : SlimeData) -> void:
	slime_manager.slime_masses_removed(slime_data.get_slime_type_masses())

func _combine_slime_masses(slime : Slime, other_slime : Slime) -> Dictionary[Constants.SlimeType, int]:
	var slime_type_masses : Dictionary[Constants.SlimeType, int] = slime.slime_data.get_slime_type_masses()
	var other_slime_type_masses : Dictionary[Constants.SlimeType, int] = other_slime.slime_data.get_slime_type_masses()
	for slime_type in other_slime_type_masses:
		if slime_type in slime_type_masses:
			slime_type_masses[slime_type] += other_slime_type_masses[slime_type]
		else:
			slime_type_masses[slime_type] = other_slime_type_masses[slime_type]
	return slime_type_masses

func _on_slimes_touch(slime_1 : Slime, slime_2 : Slime) -> void:
	for combo in Constants.combinations:
		if (slime_1.slime_type == combo.slime_1 and slime_2.slime_type == combo.slime_2) or \
			(slime_2.slime_type == combo.slime_1 and slime_1.slime_type == combo.slime_2):
			slimes_combined.emit(slime_1.slime_type, slime_2.slime_type)
			var total_mass = slime_1.mass + slime_2.mass
			var slime_result = Constants.get_slime_instance(combo.slime_result)
			add_child(slime_result)
			slime_result.global_position = (slime_1.global_position + slime_2.global_position) / 2
			slime_result.slime_data.slime_type_masses = _combine_slime_masses(slime_1, slime_2)
			slime_2.depart(1.0, false)
			slime_1.depart(1.0, false)
			_on_slime_spawned(slime_result)
			slime_result.grow(total_mass, 1.0)
			GameState.get_journal_state().add_combination(combo)

func _on_player_character_3d_slime_type_observed(slime_type, amount):
	GameState.get_journal_state().add_slime_progress(slime_type, amount)

func open_tutorials():
	for tutorial_scene in tutorial_scenes:
		var tutorial_menu : OverlaidMenu = tutorial_scene.instantiate()
		if tutorial_menu == null:
			push_warning("Tutorial failed to open %s" % tutorial_scene)
			return
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().current_scene.call_deferred("add_child", tutorial_menu)
		await tutorial_menu.tree_exited
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _ready():
	level_state = GameState.get_level_state(scene_file_path)
	if delivery_area:
		delivery_area.slime_delivered.connect(_on_slime_delivered)
	for child in get_children():
		if child is SlimeSpawner:
			child.slime_spawned.connect(_on_slime_spawned)
		if child is DeliveryInteractable:
			child.interacted.connect(delivery_area.deliver)
		if child is QuestGiver:
			child.interacted.connect(open_tutorials)
	await get_tree().create_timer(1, false).timeout
	open_tutorials()

func _exit_tree():
	GlobalState.save()
