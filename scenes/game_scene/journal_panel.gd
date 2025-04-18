extends PanelContainer

func _input(event) -> void:
	if event.is_action_pressed(&"journal"):
		visible = !visible
