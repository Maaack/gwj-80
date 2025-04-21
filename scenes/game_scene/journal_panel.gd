@tool
class_name JournalPanel
extends PanelContainer

signal journal_opened
signal journal_closed

@export var open : bool = false :
	set(value):
		open = value
		if is_inside_tree():
			_update_state()

@export var page : Constants.SlimeType = Constants.SlimeType.WATER:
	set(value):
		page = value
		if page == Constants.SlimeType.NONE or page >= Constants.SlimeType.size():
			page = Constants.SlimeType.WATER
		if is_inside_tree():
			_refresh_page()

@onready var _animation_player : AnimationPlayer = $AnimationPlayer
@onready var _refresh_timer : Timer = $RefreshTimer
@onready var combination_container: VFlowContainer = %CombinationContainer
@onready var combination_sticky_note: Control = %CombinationStickyNote
@onready var combination_overflow_container: VBoxContainer = %CombinationOverflowContainer


func _refresh_page() -> void:
	if GameState.get_journal_state() == null: return
	%PageLabel.text = "%d" % page
	var journal_state := GameState.get_journal_state()
	var progress = journal_state.get_slime_progress(page)
	if progress == 0:
		%SlimeNameLabel.text = "? ? ?"
		%DiscoveredContainer.hide()
		%ProgressContainer.show()
		%ProgressBar.value = 0.0
	else:
		%SlimeNameLabel.text = Constants.get_slime_name(page)
		%DescriptionLabel.text = Constants.get_slime_description(page)
		if journal_state.has_slime(page):
			%DiscoveredContainer.show()
			%ProgressContainer.hide()
			%TextureRect.texture = Constants.get_slime_sketch(page)
			_update_combination_container()
		else:
			%DiscoveredContainer.hide()
			%ProgressContainer.show()
			%ProgressBar.value = GameState.get_journal_state().get_slime_progress(page)

func _update_state() -> void:
	if _animation_player.is_playing(): return
	if open:
		_animation_player.play(&"OPEN")
		if not Engine.is_editor_hint():
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		_refresh_timer.start()
		_refresh_page()
		journal_opened.emit()
	else:
		_animation_player.play(&"CLOSE")
		if not Engine.is_editor_hint():
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		_refresh_timer.stop()
		journal_closed.emit()

func _input(event) -> void:
	if event.is_action_pressed(&"journal"):
		if _animation_player.is_playing(): return
		open = !open

func _on_next_button_pressed():
	page += 1

func _on_prev_button_pressed():
	page -= 1

func _on_refresh_timer_timeout():
	if open:
		_refresh_page()


func _update_combination_container() -> void:
	var relevant_combinations: Array[SlimeCombination] = Constants.get_relevant_combinations(page)
	var combo_container_child_count: int = combination_container.get_child_count()

	for i: int in combo_container_child_count:
		var slime_combination_display: SlimeCombinationDisplay = combination_container.get_child(i)

		if i >= relevant_combinations.size():
			slime_combination_display.hide()
		else:
			slime_combination_display.slime_combination = relevant_combinations[i]
			slime_combination_display.show()

	if relevant_combinations.size() > combo_container_child_count:
		combination_sticky_note.show()

		for i: int in range(combo_container_child_count, combo_container_child_count + combination_overflow_container.get_child_count()):
			var slime_combination_display: SlimeCombinationDisplay = combination_overflow_container.get_child(i - combo_container_child_count)

			if i >= relevant_combinations.size():
				slime_combination_display.hide()
			else:
				slime_combination_display.slime_combination = relevant_combinations[i]
				slime_combination_display.show()
	else:
		combination_sticky_note.hide()
