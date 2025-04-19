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
		if journal_state.has_slime(page):
			%DiscoveredContainer.show()
			%ProgressContainer.hide()
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
