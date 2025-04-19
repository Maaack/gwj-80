@tool
class_name JournalPanel
extends PanelContainer

@export var open : bool = false :
	set(value):
		open = value
		if is_inside_tree():
			_update_state()


@onready var _animation_player : AnimationPlayer = $AnimationPlayer

func _update_state() -> void:
	if _animation_player.is_playing(): return
	if open:
		_animation_player.play(&"OPEN")
	else:
		_animation_player.play(&"CLOSE")
	

func _input(event) -> void:
	if event.is_action_pressed(&"journal"):
		if _animation_player.is_playing(): return
		open = !open
