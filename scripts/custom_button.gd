extends Button

@export var scale_factor := Vector2(1.15, 1.15)
@export var tween_duration: float = 0.75

var scale_tween: Tween


func _ready() -> void:
	mouse_entered.connect(on_mouse_entered)
	mouse_exited.connect(on_mouse_exited)
	resized.connect(func () -> void: pivot_offset = size / 2)

	pivot_offset = size / 2


func on_mouse_entered() -> void:
	if disabled:
		return

	_tween_scale(scale_factor, tween_duration)


func on_mouse_exited() -> void:
	reset_scale()


func reset_scale() -> void:
	_tween_scale(Vector2.ONE, tween_duration)


func _tween_scale(new_scale: Vector2, duration: float) -> void:
	if scale_tween and scale_tween.is_running():
		scale_tween.kill()
	scale_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	scale_tween.tween_property(self, "scale", new_scale, duration)


## Overrides the disabled setter to also reset the button's scale if the button is disabled.
func _set(property: StringName, value: Variant) -> bool:
	if property == "disabled":
		disabled = value
		if value:
			reset_scale()
		return true
	return false
