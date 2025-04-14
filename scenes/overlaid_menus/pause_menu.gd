extends PauseMenu

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _exit_tree():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
